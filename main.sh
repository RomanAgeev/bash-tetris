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
    shape_view__set_color "${COLORS[$color_index]}"
    shape_view__enable_auto_render
}

on_action() {
    case $1 in
        A)
            shape_view__disable_auto_render
            shape_view__rotate_right
            is_shape_right && {
                local most_right_col; get_shape_most_right_col most_right_col
                SHAPE_COL=$most_right_col
            }
            is_shape_down && {
                local most_bottom_row; get_shape_most_bottom_row most_bottom_row
                SHAPE_ROW=$most_bottom_row
            }
            shape_view__move_at $SHAPE_ROW $SHAPE_COL
            shape_view__enable_auto_render
            ;;
        B) is_shape_down || shape_view__move_down ;;
        C) is_shape_right || shape_view__move_right ;;
        D) is_shape_left || shape_view__move_left ;;
        '')
            local most_bottom_row; get_shape_most_bottom_row most_bottom_row
            shape_view__move_at $most_bottom_row $SHAPE_COL
            next_shape
            ;;
        q) exit ;;
        *) return 1 ;;
    esac
}

on_timeout() {
    is_shape_down && next_shape || shape_view__move_down
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
