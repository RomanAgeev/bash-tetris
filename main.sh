#!/bin/bash

set -uo pipefail

source ./shape.sh
source ./shape_view.sh
source ./canvas.sh
source ./loop.sh

set_shape_view_default_placeholder O

new_canvas stage
hide_cursor stage
new_canvas final
show_cursor final

clear
render_canvas stage

# new_shape shape "xx xx"
# new_shape shape "xx. .xx"
# new_shape shape "x.. xxx"
# new_shape shape "xxxx"
# new_shape shape "..x xxx"
# new_shape shape ".xx xx."

new_shape shape ".x. xxx"
new_shape_view view shape
set_shape_view_color view "$CYAN"
move_shape_view_at view 10 80
enabled_shape_view_render view

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
    move_shape_view_down view 1
}

trap "render_canvas final; echo" EXIT

loop _loop_handler _timeout_handler 500
