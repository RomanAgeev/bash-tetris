#!/bin/bash

set -uo pipefail

source ./utils/_main.sh
source ./shape.sh
source ./shape_view.sh
source ./canvas.sh
source ./stage.sh
source ./loop.sh

require bc

SHAPES=("xx xx" "xx. .xx" "x.. xxx" "xxxx" "..x xxx" ".xx xx." ".x. xxx")
COLORS=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN" "$WHITE")

shape_view__set_placeholder "O"
set_foreground "$NEUTRAL"
set_background "$NEUTRAL"
init_stage 10 60 50 30

next_shape() {
    shape_view__free view

    local shape_index=$(( $RANDOM % ${#SHAPES[@]} ))
    local color_index=$(( $RANDOM % ${#COLORS[@]} ))

    shape__new shape "${SHAPES[$shape_index]}"
    drop_shape shape view
    shape_view__set_color view "${COLORS[$color_index]}"
    shape_view__enable_auto_render view
}

on_action() {
    case $1 in
        A)
            shape_view__disable_auto_render view
            shape_view__rotate_right view
            local view_row; shape_view__get_row view view_row
            local view_col; shape_view__get_col view view_col
            is_shape_right view && {
                local most_right_col; get_shape_most_right_col view most_right_col
                view_col=$most_right_col
            }
            is_shape_down view && {
                local most_bottom_row; get_shape_most_bottom_row view most_bottom_row
                view_row=$most_bottom_row
            }
            shape_view__move_at view $view_row $view_col
            shape_view__enable_auto_render view
            ;;
        B) is_shape_down view || shape_view__move_down view ;;
        C) is_shape_right view || shape_view__move_right view ;;
        D) is_shape_left view || shape_view__move_left view ;;
        '')
            local most_bottom_row; get_shape_most_bottom_row view most_bottom_row
            local view_col; shape_view__get_col view view_col
            shape_view__move_at view $most_bottom_row $view_col
            next_shape
            ;;
        q) exit ;;
        *) return 1 ;;
    esac
}

on_timeout() {
    is_shape_down view && next_shape || shape_view__move_down view
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
