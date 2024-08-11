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
STAGE_WIDTH=50
STAGE_HEIGHT=30
STAGE_BOTTOM=$(( $STAGE_ROW + $STAGE_HEIGHT ))
STAGE_RIGHT=$(( $STAGE_COL + $STAGE_WIDTH ))
STAGE_INNER=$(( $STAGE_WIDTH - 1 ))
SHAPES=("xx xx" "xx. .xx" "x.. xxx" "xxxx" "..x xxx" ".xx xx." ".x. xxx")
COLORS=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN" "$WHITE")

next_shape() {
    local shape_index=$(( $RANDOM % ${#SHAPES[@]} ))
    local color_index=$(( $RANDOM % ${#COLORS[@]} ))
    init_shape "${SHAPES[$shape_index]}" "${COLORS[$color_index]}" $STAGE_ROW $(( $STAGE_COL + $STAGE_WIDTH / 2 - 1 )) "$PLACEHOLDER"
    calc_shape_actual_size
    render_shape
}

is_shape_down() {
    [ $(( $SHAPE_ROW + $SHAPE_ACTUAL_HEIGHT )) -ge $STAGE_BOTTOM ]
}

is_shape_left() {
    [ $SHAPE_COL -le $(( $STAGE_COL + 1 )) ]
}

is_shape_right() {
    [ $(( $SHAPE_COL + $SHAPE_ACTUAL_WIDTH )) -ge $STAGE_RIGHT ]
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
        A)
            SHAPE_ROTATION=$(( ($SHAPE_ROTATION + 1) % 4 ))
            calc_shape_actual_size
            is_shape_right && SHAPE_COL=$(( $STAGE_RIGHT - $SHAPE_ACTUAL_WIDTH))
            is_shape_down && SHAPE_ROW=$(( $STAGE_BOTTOM - $SHAPE_ACTUAL_HEIGHT ))
            render_shape
            ;;
        B) is_shape_down || {
            SHAPE_ROW=$(( $SHAPE_ROW + 1 ))
            render_shape
        } ;;
        C) is_shape_right || {
            SHAPE_COL=$(( $SHAPE_COL + 1 ))
            render_shape
        } ;;
        D) is_shape_left || {
            SHAPE_COL=$(( $SHAPE_COL - 1 ))
            render_shape
        } ;;
        '')
            SHAPE_ROW=$(( $STAGE_BOTTOM - $SHAPE_ACTUAL_HEIGHT ))
            render_shape
            next_shape
            ;;
        q) exit ;;
        *) return 1 ;;
    esac
}

on_timeout() {
    (is_next_heap_hit || is_shape_down) && {
        update_heap
        render_heap
        next_shape
    } || {
        SHAPE_ROW=$(( $SHAPE_ROW + 1 ))
        render_shape
    }
}

on_exit() {
    clear
    show_cursor
}

trap "on_exit" EXIT

clear
set_foreground "$NEUTRAL"
set_background "$NEUTRAL"
hide_cursor
render_stage
init_heap
next_shape

loop on_action on_timeout 100
