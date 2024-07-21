#!/bin/bash

set -euo pipefail

source ./shape.sh
source ./shape_view.sh
source ./canvas.sh

set_shape_view_default_placeholder O

# new_shape shape_o "xx xx"
# new_shape shape_z "xx. .xx"
# new_shape shape_j "x.. xxx"
# new_shape shape_i "xxxx"
# new_shape shape_l "..x xxx"
# new_shape shape_s ".xx xx."

clear

new_canvas stage
hide_cursor stage
render_canvas stage

new_shape shape ".x. xxx"
new_shape_view view shape
move_shape_view_at view 30 80

while :; do
    while :; do
        read -sn 1 key

        case $key in
            A) move_shape_view_up view; break ;;
            B) move_shape_view_down view; break ;;
            C) move_shape_view_right view; break ;;
            D) move_shape_view_left view; break ;;
            z|Z) rotate_shape_view_left view; break ;;
            x|X) rotate_shape_view_right view; break ;;
            q) new_canvas final
                show_cursor final
                render_canvas final
                echo; exit ;;
        esac
    done
done
