#!/bin/bash

set -uo pipefail

source ./utils/_main.sh
source ./shape.sh
source ./canvas.sh
source ./stage.sh
source ./loop.sh

require bc
require gdate

SHAPES=("xx xx" "xx. .xx" "x.. xxx" "xxxx" "..x xxx" ".xx xx." ".x. xxx")
COLORS=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN" "$WHITE")

set_foreground "$NEUTRAL"
set_background "$NEUTRAL"
init_stage 10 60 50 30

next_shape() {
    local shape_index=$(( $RANDOM % ${#SHAPES[@]} ))
    local color_index=$(( $RANDOM % ${#COLORS[@]} ))

    init_shape "${SHAPES[$shape_index]}" "${COLORS[$color_index]}"
    drop_shape
    render_shape
}

on_action() {
    update_shape_actual_size
    case $1 in
        A)
            SHAPE_ROTATION=$(( ($SHAPE_ROTATION + 1) % 4 ))
            is_shape_right && SHAPE_COL=$(( $RIGHT - $SHAPE_ACTUAL_WIDTH))
            is_shape_down && SHAPE_ROW=$(( $BOTTOM - $SHAPE_ACTUAL_HEIGHT ))
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
            SHAPE_ROW=$(( $BOTTOM - $SHAPE_ACTUAL_HEIGHT ))
            render_shape
            next_shape
            ;;
        q) exit ;;
        *) return 1 ;;
    esac
}

on_timeout() {
    update_shape_actual_size
    is_shape_down && next_shape || {
        SHAPE_ROW=$(( $SHAPE_ROW + 1 ))
        render_shape
    }
}

on_exit() {
    clear
    show_cursor
    echo
}

trap "on_exit" EXIT

clear
hide_cursor
render_stage
next_shape

loop on_action on_timeout 300
