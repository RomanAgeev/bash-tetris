#!/bin/bash

set -uo pipefail
shopt -s extglob

ESC=$'\e'
CSI=$ESC[
CUR_HIDE="${CSI}?25l"
CUR_SHOW="${CSI}?25h"
CUR_ROW_COL="${CSI}%d;%dH"
CUR_SAVE="${CSI}s"
CUR_RESTORE="${CSI}u"
CUR_UP_N="${CSI}%sA"
CUR_DOWN_N="${CSI}%sB"
CUR_RIGHT_N="${CSI}%sC"

printf -v CUR_UP "$CUR_UP_N" "1"
printf -v CUR_DOWN "$CUR_DOWN_N" "1"
printf -v CUR_RIGHT "$CUR_RIGHT_N" "1"

TRANSPARENT=-1
BLACK=0
RED=1
GREEN=2
YELLOW=3
BLUE=4
MAGENTA=5
CYAN=6
WHITE=7

FG="${CSI}3%dm"

WALL_LEFT='\U258F'
WALL_RIGHT='\U2595'
FLOOR='\U2594'
PLACEHOLDER='\U2586'

STAGE_WIDTH=20
STAGE_HEIGHT=15

shopt -s checkwinsize; (:);

(( STAGE_LEFT = COLUMNS / 2 - STAGE_WIDTH / 2 ))
(( STAGE_TOP = LINES / 2 - STAGE_HEIGHT / 2 ))
(( STAGE_RIGHT = STAGE_LEFT + STAGE_WIDTH + 1 ))
(( STAGE_BOTTOM = STAGE_TOP + STAGE_HEIGHT ))

IFS_BAK=$IFS; IFS=$'\n'; SHAPES=( $(< ${1:-./shapes/tetramino.cfg}) ); IFS=$IFS_BAK
COLORS=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN" "$WHITE")

HEAP_WIDTH=()
for (( i = 0; i < STAGE_WIDTH; i++ )); do
    eval "HEAP_$i=()"
done

INIT_TIMEOUT_MS=500

hide_cursor() {
    printf "$CUR_HIDE"
}

show_cursor() {
    printf "$CUR_SHOW"
}

reset_fg() {
    printf "$FG" "$BLACK"
}

#--------- Begin Canvas ---------#

new_canvas() {
    CANVAS=
}

set_canvas_foreground() {
    local suffix; printf -v suffix "$FG" "${1:?}"
    append_canvas_suffix "$suffix"
}

set_canvas_cursor_at() {
    append_canvas_suffix "$CUR_ROW_COL" "${1:?}" "${2:?}"
}

add_canvas_format() {
    local format="${1:?}"
    shift 1
    append_canvas_suffix "$format" "$@"
}

add_canvas_format_line() {
    local format="${1:?}"
    shift 1
    append_canvas_suffix "$CUR_SAVE$format$CUR_RESTORE$CUR_DOWN" "$@"
}

render_canvas() {
    printf "$CANVAS\n" "$@"
    reset_fg
}

append_canvas_suffix() {
    local format="${1:?}"
    shift 1
    local suffix; (( $# > 0 )) && printf -v suffix "$format" "$@" || suffix="$format"
    CANVAS="$CANVAS$suffix"
}

#--------- End Canvas ---------#

#--------- Begin Shape ---------#

new_shape() {
    local string="${1:?}"
    local color="${2:?}"

    local lines
    local IFS
    IFS=' ' read -r -a lines <<< "$string"

    SHAPE_WIDTH=
    for line in "${lines[@]}"; do
        local line_width="${#line}"
        if [ $line_width -ne ${SHAPE_WIDTH:=$line_width} ]; then
            printf "Shape \"%s\"is not rectangular\n" "$string" >&2
            return 1
        fi
    done

    SHAPE_HEIGHT="${#lines[@]}"
    ((SHAPE_LENGTH = SHAPE_WIDTH * SHAPE_HEIGHT ))

    init_shape_format 0 "${lines[@]}"
    init_shape_format 1 "${lines[@]}"
    init_shape_format 2 "${lines[@]}"
    init_shape_format 3 "${lines[@]}"

    SHAPE_CANVAS=
    SHAPE_ROTATION=0
    SHAPE_COLOR="$color"

    SHAPE_PLACEHOLDERS=()
    SHAPE_SPACES=()
    for (( i = 0; i < SHAPE_LENGTH; i++ )); do
        SHAPE_PLACEHOLDERS+=( "$PLACEHOLDER" )
        SHAPE_SPACES+=( " " )
    done

    calc_shape_actual_size
}

render_shape() {
    clear_shape

    eval "local format=( \"\${SHAPE_FORMAT_$SHAPE_ROTATION[@]}\" )"

    new_canvas
    set_canvas_foreground "$SHAPE_COLOR"
    set_canvas_cursor_at "$SHAPE_ROW" "$SHAPE_COL"
    for line in "${format[@]}"; do
        add_canvas_format_line "$line"
    done

    render_canvas "${SHAPE_PLACEHOLDERS[@]}"

    SHAPE_CANVAS=$CANVAS
}

clear_shape() {
    if [ -n "$SHAPE_CANVAS" ]; then
        CANVAS="$SHAPE_CANVAS"
        render_canvas "${SHAPE_SPACES[@]}"
    fi
}

init_shape_format() {
    local rotation="${1:?}"

    shift 1

    eval "init_shape_lines_$rotation \"\$@\""
    eval "local lines=( \"\${SHAPE_LINES_$rotation[@]}\" )"

    local format=()
    for line in "${lines[@]}"; do
        local line_format=
        local line_length=${#line}
        while (( line_length > 0 )); do
            local empty_tail="${line#+(.)}"
            local empty_length; (( empty_length = line_length - ${#empty_tail} ))

            (( empty_length > 0 )) && {
                local empty;
                printf -v empty "$CUR_RIGHT_N" "$empty_length"
                line_format="$line_format$empty"
                line_length=${#empty_tail}
                line="$empty_tail"
            }

            local full_tail="${line#+([^.])}"
            local full_length; (( full_length = line_length - ${#full_tail} ))

            (( full_length > 0 )) && {
                local full="${line:0:$full_length}"
                line_format="$line_format${full//[^.]/%b}"
                line_length=${#full_tail}
                line="$full_tail"
            }
        done
        format+=( "$line_format" )
    done

    eval "SHAPE_FORMAT_$rotation=( \"\${format[@]}\" )"
}

init_shape_lines_0() {
    SHAPE_LINES_0=( $@ )
}

init_shape_lines_1() {
    local lines=( $@ )

    SHAPE_LINES_1=()
    for (( i = 0; i < SHAPE_WIDTH; i++ )); do
        local line=""
        for (( j = SHAPE_HEIGHT-1; j >= 0; j-- )); do
            line=$line"${lines[$j]:$i:1}"
        done
        SHAPE_LINES_1+=( "$line" )
    done
}

init_shape_lines_2() {
    local lines=( $@ )

    SHAPE_LINES_2=()
    for (( j = SHAPE_HEIGHT - 1; j >= 0; j-- )); do
        local line=""
        for (( i = SHAPE_WIDTH - 1; i >= 0; i-- )); do
            line=$line"${lines[$j]:$i:1}"
        done
        SHAPE_LINES_2+=( "$line" )
    done
}

init_shape_lines_3() {
    local lines=( $@ )

    SHAPE_LINES_3=()
    for (( i = SHAPE_WIDTH - 1; i >= 0; i-- )); do
        local line=""
        for (( j = 0; j < SHAPE_HEIGHT; j++ )); do
            line=$line"${lines[$j]:$i:1}"
        done
        SHAPE_LINES_3+=( "$line" )
    done
}

calc_shape_actual_size() {
    [ $(( SHAPE_ROTATION % 2 )) -eq 0 ] && {
        SHAPE_ACTUAL_WIDTH=$SHAPE_WIDTH
        SHAPE_ACTUAL_HEIGHT=$SHAPE_HEIGHT
    } || {
        SHAPE_ACTUAL_WIDTH=$SHAPE_HEIGHT
        SHAPE_ACTUAL_HEIGHT=$SHAPE_WIDTH
    }
}

#--------- End Shape ---------#

#--------- Begin Heap ---------#

set_heap_item() {
    eval "HEAP_${1:?}[${2:?}]=\"\${3:?}\""
}

get_heap_item() {
    eval "heap_item=\${HEAP_${1:?}[${2:?}]-$TRANSPARENT}"
}

has_heap_item() {
    eval "[ -n \"\${HEAP_${1:?}[${2:?}]-}\" ]"
}

get_heap_height() {
    eval "heap_height=\${#HEAP_${1:?}[@]}"
}

calc_heap_max_height() {
    HEAP_MAX_HEIGHT=${#HEAP_WIDTH[@]}
}

render_heap() {
    local from=${1:?}
    local to=${2:?}
    new_canvas
    for (( i = 0; i < STAGE_WIDTH; i++ )); do
        for (( j = from; j <= to; j++ )); do
            local heap_item; get_heap_item $i $j
            local placeholder; (( heap_item != $TRANSPARENT )) && placeholder="$PLACEHOLDER" || placeholder=" "
            set_canvas_cursor_at $(( STAGE_BOTTOM - j - 1 )) $(( STAGE_LEFT + i + 1 ))
            set_canvas_foreground $heap_item
            add_canvas_format "%s" "$placeholder"
        done
    done
    render_canvas
}

is_heap_hit() {
    local left=$SHAPE_COL
    local top=$SHAPE_ROW
    local right; (( right = left + SHAPE_ACTUAL_WIDTH - 1 ))
    local bottom; (( bottom = top + SHAPE_ACTUAL_HEIGHT - 1 ))

    eval "local shape_lines=( \"\${SHAPE_LINES_$SHAPE_ROTATION[@]}\" )"

    for (( i = 0; i < SHAPE_ACTUAL_WIDTH; i++ )); do
        local heap_i; (( heap_i = left - STAGE_LEFT + i - 1 ))
        local heap_height; get_heap_height $heap_i
        local heap_top; (( heap_top = STAGE_BOTTOM - heap_height ))
        (( heap_top < top )) && heap_top=$top
        for (( j = heap_top; j <= bottom; j++ )); do
            local line_j; (( line_j = j - top ))
            local heap_j; (( heap_j = STAGE_BOTTOM - j - 1 ))
            local shape_line="${shape_lines[$line_j]}"
            local heap_item; get_heap_item $heap_i $heap_j
            ([ "${shape_line:$i:1}" != "." ] && (( heap_item != $TRANSPARENT ))) && return 0
        done
    done
    return 1
}

update_heap() {
    eval "local shape_lines=( \"\${SHAPE_LINES_$SHAPE_ROTATION[@]}\" )"
    for (( i = 0; i < SHAPE_ACTUAL_WIDTH; i++ )); do
        local heap_i; (( heap_i = SHAPE_COL - STAGE_LEFT + i - 1 ))
        local heap_height; get_heap_height $heap_i

        local j=0
        for (( ; j < SHAPE_ACTUAL_HEIGHT; j++ )); do
            local shape_line="${shape_lines[$j]}"
            [ "${shape_line:$i:1}" != "." ] && break
        done

        (( j == SHAPE_ACTUAL_HEIGHT )) && continue

        local heap_j
        for (( ; j < SHAPE_ACTUAL_HEIGHT; j++ )); do
            (( heap_j = STAGE_BOTTOM - SHAPE_ROW - j - 1 ))
            local shape_line="${shape_lines[$j]}"
            if [ "${shape_line:$i:1}" != "." ]; then
                set_heap_item $heap_i $heap_j $SHAPE_COLOR
                local heap_width=${HEAP_WIDTH[$heap_j]-0}
                (( heap_width = heap_width + 1 ))
                HEAP_WIDTH[$heap_j]=$heap_width
            elif ! has_heap_item $heap_i $heap_j; then
                set_heap_item $heap_i $heap_j $TRANSPARENT
            fi
        done

        for (( k = heap_j - 1; k >= heap_height; k-- )); do
            set_heap_item $heap_i $k $TRANSPARENT
        done
    done
}

shrink_heap() {
    calc_heap_max_height

    local row=
    for (( j = 0; j < HEAP_MAX_HEIGHT; j++ )); do
        [ ${HEAP_WIDTH[$j]} -eq $STAGE_WIDTH ] && {
            row=$j
            break
        }
    done

    [ -z "$row" ] && return 1

    for (( (( j = HEAP_MAX_HEIGHT - 1)); j >= $row; j-- )); do
        [ ${HEAP_WIDTH[$j]} -eq $STAGE_WIDTH ] && {
            unset HEAP_WIDTH[$j]
            for (( i = 0; i < $STAGE_WIDTH; i++ )); do
                eval "unset HEAP_$i[$j]"
            done
        }
    done

    for (( i = 0; i < STAGE_WIDTH; i++ )); do
        eval "HEAP_$i=( \"\${HEAP_$i[@]}\" )"
    done
    HEAP_WIDTH=( "${HEAP_WIDTH[@]}" )
}

shrink_heap_cascade() {
    calc_heap_max_height
    local heap_max_height=$HEAP_MAX_HEIGHT
    while shrink_heap; do (:); done
    render_heap 0 $(( heap_max_height - 1 ))
}

#--------- End Heap ---------#

#--------- Begin Stage ---------#

render_stage() {
    local line;
    printf -v line "$WALL_LEFT%$STAGE_WIDTH.${STAGE_WIDTH}s$WALL_RIGHT" " "

    new_canvas
    set_canvas_foreground $WHITE
    set_canvas_cursor_at $STAGE_TOP $STAGE_LEFT
    for (( i = 0; i < STAGE_HEIGHT; i++ )); do
        add_canvas_format_line "$line"
    done

    local bottom_line;
    printf -v bottom_line " %$STAGE_WIDTH.${STAGE_WIDTH}s " " "
    bottom_line="${bottom_line// /$FLOOR}"
    add_canvas_format_line "$bottom_line"
    add_canvas_format_line "Press <p> for pause/unpause."
    add_canvas_format_line "Press <q> for exit."

    render_canvas
}

#--------- End Stage ---------#

next_shape() {
    local shape_index; (( shape_index = RANDOM % ${#SHAPES[@]} ))
    local color_index; (( color_index = RANDOM % ${#COLORS[@]} ))
    new_shape "${SHAPES[$shape_index]}" "${COLORS[$color_index]}"
    move_shape_start
    is_heap_hit && game_over || render_shape
}

game_over() {
    new_canvas
    set_canvas_foreground "$RED"
    set_canvas_cursor_at $(( STAGE_BOTTOM + 4 )) $(( STAGE_LEFT ))
    add_canvas_format_line "GAME OVER !"
    add_canvas_format_line "Press any key to exit..."
    render_canvas
    read -sn 1
    exit 0
}

move_shape_start() {
    (( SHAPE_ROW = STAGE_TOP ))
    (( SHAPE_COL = STAGE_LEFT + STAGE_WIDTH / 2 ))
}

move_shape_right() {
    (( SHAPE_COL = SHAPE_COL + 1 ))
}

move_shape_left() {
    (( SHAPE_COL = SHAPE_COL - 1 ))
}

move_shape_down() {
    (( SHAPE_ROW = SHAPE_ROW + 1 ))
}

move_shape_up() {
    (( SHAPE_ROW = SHAPE_ROW - 1 ))
}

rotate_shape_right() {
    (( SHAPE_ROTATION = ($SHAPE_ROTATION + 1) % 4 ))
    calc_shape_actual_size
}

rotate_shape_left() {
    (( SHAPE_ROTATION = SHAPE_ROTATION - 1 ))
    [ $SHAPE_ROTATION -lt 0 ] && (( SHAPE_ROTATION = 4 + SHAPE_ROTATION ))
    calc_shape_actual_size
}

is_shape_down() {
    [ $(( SHAPE_ROW + SHAPE_ACTUAL_HEIGHT )) -gt $STAGE_BOTTOM ]
}

is_shape_left() {
    [ $SHAPE_COL -le $STAGE_LEFT ]
}

is_shape_right() {
    [ $(( SHAPE_COL + SHAPE_ACTUAL_WIDTH )) -gt $STAGE_RIGHT ]
}

try_rotate_shape() {
    rotate_shape_right
    (is_shape_right || is_shape_left || is_heap_hit) &&  rotate_shape_left || render_shape
}

try_move_shape_left() {
    move_shape_left
    (is_shape_left || is_heap_hit) && move_shape_right || render_shape
}

try_move_shape_right() {
    move_shape_right
    (is_shape_right || is_heap_hit) && move_shape_left || render_shape
}

try_move_shape_down() {
    move_shape_down
    (is_shape_down || is_heap_hit) && {
        move_shape_up
        update_heap
        shrink_heap_cascade
        next_shape
    } || {
        render_shape
    }
}

drop_shape_down() {
    local shape_row_before=$SHAPE_ROW

    calc_heap_max_height
    local shape_bottom; (( shape_bottom = SHAPE_ROW + SHAPE_ACTUAL_HEIGHT ))
    local heap_top; (( heap_top = STAGE_BOTTOM - HEAP_MAX_HEIGHT ))
    (( shape_bottom < heap_top )) && (( SHAPE_ROW = heap_top - SHAPE_ACTUAL_HEIGHT ))

    move_shape_down
    while (! is_shape_down && ! is_heap_hit); do
        move_shape_down
    done
    move_shape_up

    (( SHAPE_ROW != shape_row_before )) && clear_shape

    update_heap
    shrink_heap_cascade
    next_shape
}

to_timeout_sec() {
    [ $TIMEOUT_MS -lt 0 ] && TIMEOUT_MS=0
    [ $TIMEOUT_MS -ge 1000 ] && TIMEOUT_SEC="${TIMEOUT_MS%???}.${TIMEOUT_MS: -3}" || printf -v TIMEOUT_SEC "0.%03d" $TIMEOUT_MS
}

flip_paused() {
    is_paused && unset PAUSE || PAUSE=Y
}

is_paused() {
    [ -n "${PAUSE-}" ]
}

on_key_press() {
    case $1 in
        A) try_rotate_shape ;;
        B) try_move_shape_down ;;
        C) try_move_shape_right ;;
        D) try_move_shape_left ;;
        '') drop_shape_down ;;
        *) return 1 ;;
    esac
}

on_exit() {
    clear
    show_cursor
}

trap "on_exit" EXIT

clear
reset_fg
hide_cursor
render_stage
next_shape

TIMEOUT_MS=$INIT_TIMEOUT_MS
while :; do
    TS_BEFORE=$( gdate +%s%3N )
    to_timeout_sec
    while :; do
        read -sn 1 -t $TIMEOUT_SEC key || {
            is_paused || try_move_shape_down
            TIMEOUT_MS=$INIT_TIMEOUT_MS
            TS_BEFORE=$( gdate +%s%3N )
            to_timeout_sec
            continue
        }
        [[ "$key" =~ q|Q ]] && exit
        [[ "$key" =~ p|P ]] && flip_paused
        is_paused || on_key_press "$key" && break
    done
    TS_AFTER=$( gdate +%s%3N )
    (( TIMEOUT_MS = TIMEOUT_MS - TS_AFTER + TS_BEFORE ))
done
