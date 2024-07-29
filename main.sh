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

clear
hide_cursor

new_stage stage 10 60 50 30
render_stage stage

get_stage_start_position stage shape_row shape_col

_new_shape() {
    free_shape shape
    free_shape_view view

    local shape_index=$(( $RANDOM % ${#shapes[@]} ))

    new_shape shape "${shapes[$shape_index]}"
    new_shape_view view shape
    set_shape_view_color view "$CYAN"
    enabled_shape_view_render view

    echo $shape_row $shape_col

    move_shape_view_at view $shape_row $shape_col
}

_loop_handler() {
    local key="${1:?}"

    case $key in
        A) move_shape_view_up view ;;
        B) move_shape_view_down view ;;
        C) move_shape_view_right view ;;
        D) move_shape_view_left view ;;
        z|Z) rotate_shape_view_left view ;;
        x|X) rotate_shape_view_right view ;;
        q) exit ;;
        *) return 1 ;;
    esac
}

_timeout_handler() {
    local view_row; get_shape_view_row view view_row
    local view_rotation; get_shape_view_rotation view view_rotation
    local shape_height; get_shape_actual_height shape "$view_rotation" shape_height
    local stage_bottom; get_stage_bottom stage stage_bottom

    [ $(( $view_row + $shape_height )) -lt $stage_bottom ] && move_shape_view_down view 1 || _new_shape
}

trap "clear; show_cursor; echo" EXIT

_new_shape

loop _loop_handler _timeout_handler 500
