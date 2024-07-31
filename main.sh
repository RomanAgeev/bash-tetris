#!/bin/bash

set -uo pipefail

source ./utils/_main.sh
source ./shape.sh
source ./shape_view.sh
source ./canvas.sh
source ./stage.sh
source ./loop.sh

require bc

set_shape_view_default_placeholder O
set_foreground "$NEUTRAL"
set_background "$NEUTRAL"

shapes=("xx xx" "xx. .xx" "x.. xxx" "xxxx" "..x xxx" ".xx xx." ".x. xxx")
colors=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN" "$WHITE")

clear
hide_cursor

init_stage 10 60 50 30
render_stage

_new_shape() {
    free_shape_view view

    local shape_index=$(( $RANDOM % ${#shapes[@]} ))
    local color_index=$(( $RANDOM % ${#colors[@]} ))

    new_shape shape "${shapes[$shape_index]}"

    drop_shape shape view

    set_shape_view_color view "${colors[$color_index]}"
    enabled_shape_view_render view
}

_loop_handler() {
    local key="${1:?}"

    case $key in
        A)
            disable_shape_view_render view
            rotate_shape_view_left view
            is_shape_right view && {
                local view_row; get_shape_view_row view view_row
                local most_right_col; get_shape_most_right_col view most_right_col
                move_shape_view_at view $view_row $most_right_col
            }
            enabled_shape_view_render view
            ;;
        B)
            local most_bottom_row; get_shape_most_bottom_row view most_bottom_row
            local view_col; get_shape_view_col view view_col
            move_shape_view_at view $most_bottom_row $view_col
            _new_shape
            ;;
        C) is_shape_right view || move_shape_view_right view ;;
        D) is_shape_left view || move_shape_view_left view ;;
        q) exit ;;
        *) return 1 ;;
    esac
}

_timeout_handler() {
    is_shape_down view && _new_shape || move_shape_view_down view
}

shutdown() {
    free_shape_view view
    clear
    show_cursor
    echo
}

trap "shutdown" EXIT

_new_shape

loop _loop_handler _timeout_handler 300
