#!/bin/bash

set -uo pipefail

source ./utils/_main.sh
source ./shape.sh
source ./shape_view.sh
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

    init_shape "${SHAPES[$shape_index]}"
    drop_shape
    set_shape_color "${COLORS[$color_index]}"
    enable_shape_auto_render
}

on_action() {
    init_shape_actual_size
    case $1 in
        A)
            disable_shape_auto_render
            rotate_shape
            is_shape_right && SHAPE_COL=$(( $RIGHT - $SHAPE_ACTUAL_WIDTH))
            is_shape_down && SHAPE_ROW=$(( $BOTTOM - $SHAPE_ACTUAL_HEIGHT ))
            move_shape_at $SHAPE_ROW $SHAPE_COL
            enable_shape_auto_render
            ;;
        B) is_shape_down || move_shape_down ;;
        C) is_shape_right || move_shape_right ;;
        D) is_shape_left || move_shape_left ;;
        '')
            move_shape_at $(( $BOTTOM - $SHAPE_ACTUAL_HEIGHT )) $SHAPE_COL
            next_shape
            ;;
        q) exit ;;
        *) return 1 ;;
    esac
}

on_timeout() {
    init_shape_actual_size
    is_shape_down && next_shape || move_shape_down
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
