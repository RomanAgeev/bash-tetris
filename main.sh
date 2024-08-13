#!/bin/bash

set -uo pipefail
shopt -s extglob

source ./utils/_main.sh
source ./shape.sh
source ./canvas.sh
source ./loop.sh
source ./heap.sh

require bc
require gdate

WALL="|"
FLOOR=_
PLACEHOLDER=O
STAGE_ROW=10
STAGE_COL=60
STAGE_WIDTH=5
STAGE_HEIGHT=15
STAGE_BOTTOM=$(( $STAGE_ROW + $STAGE_HEIGHT ))
STAGE_RIGHT=$(( $STAGE_COL + $STAGE_WIDTH ))
STAGE_INNER=$(( $STAGE_WIDTH - 1 ))
# SHAPES=("xx xx" "xx. .xx" "x.. xxx" "xxxx" "..x xxx" ".xx xx." ".x. xxx")
SHAPES=("x.. xxx" "..x xxx")
COLORS=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN" "$WHITE")

next_shape() {
    local shape_index=$(( $RANDOM % ${#SHAPES[@]} ))
    local color_index=$(( $RANDOM % ${#COLORS[@]} ))
    init_shape "${SHAPES[$shape_index]}" "${COLORS[$color_index]}" $STAGE_ROW $(( $STAGE_COL + $STAGE_WIDTH / 2 - 1 )) "$PLACEHOLDER"
    calc_shape_actual_size
    render_shape
}

move_shape_right() {
    SHAPE_COL=$(( $SHAPE_COL + 1 ))
}

move_shape_left() {
    SHAPE_COL=$(( $SHAPE_COL - 1 ))
}

move_shape_down() {
    SHAPE_ROW=$(( $SHAPE_ROW + 1 ))
}

move_shape_up() {
    SHAPE_ROW=$(( $SHAPE_ROW - 1 ))
}

rotate_shape_right() {
    SHAPE_ROTATION=$(( ($SHAPE_ROTATION + 1) % 4 ))
    calc_shape_actual_size
}

rotate_shape_left() {
    SHAPE_ROTATION=$(( $SHAPE_ROTATION - 1 ))
    [ $SHAPE_ROTATION -lt 0 ] && SHAPE_ROTATION=$(( 4 + $SHAPE_ROTATION ))
    calc_shape_actual_size
}

is_shape_down() {
    [ $(( $SHAPE_ROW + $SHAPE_ACTUAL_HEIGHT )) -gt $STAGE_BOTTOM ]
}

is_shape_left() {
    [ $SHAPE_COL -le $STAGE_COL ]
}

is_shape_right() {
    [ $(( $SHAPE_COL + $SHAPE_ACTUAL_WIDTH )) -gt $STAGE_RIGHT ]
}

calc_shape_actual_size() {
    [ $(( $SHAPE_ROTATION % 2 )) -eq 0 ] && {
        SHAPE_ACTUAL_WIDTH=$SHAPE_WIDTH
        SHAPE_ACTUAL_HEIGHT=$SHAPE_HEIGHT
    } || {
        SHAPE_ACTUAL_WIDTH=$SHAPE_HEIGHT
        SHAPE_ACTUAL_HEIGHT=$SHAPE_WIDTH
    }
}

render_stage() {
    local line;
    printf -v line "$WALL%$STAGE_INNER.${STAGE_INNER}s$WALL" " "

    init_canvas
    set_canvas_foreground $WHITE
    set_canvas_cursor_at $STAGE_ROW $STAGE_COL
    for (( i = 0; i<$STAGE_HEIGHT - 1; i++ )); do
        add_canvas_format_line "$line"
    done

    local bottom_line;
    printf -v bottom_line "$WALL%$STAGE_INNER.${STAGE_INNER}s$WALL" " "
    bottom_line="${bottom_line// /$FLOOR}"
    add_canvas_format_line "$bottom_line"

    render_canvas
}

on_action() {
    case $1 in
        A) try_rotate_shape ;;
        B) try_move_shape_down ;;
        C) try_move_shape_right ;;
        D) try_move_shape_left ;;
        '') drop_shape_down ;;
        q) exit ;;
        *) return 1 ;;
    esac
}

on_timeout() {
    :; # try_move_shape_down
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
        adjust_heap
        next_shape
    } || {
        render_shape
    }
}

drop_shape_down() {
    move_shape_down
    while (! is_shape_down && ! is_heap_hit); do
        move_shape_down
    done
    move_shape_up
    clear_shape
    update_heap
    adjust_heap
    next_shape
}

on_exit() {
    # clear
    show_cursor
}

trap "on_exit" EXIT

clear
# set_foreground "$NEUTRAL"
# set_background "$NEUTRAL"
hide_cursor
render_stage
init_heap
next_shape

loop on_action on_timeout 300
