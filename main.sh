#!/bin/bash

set -euo pipefail

source ./shape.sh

set_shape_default_placeholder O

new_shape shape_o "xx xx"
new_shape shape_z "xx. .xx"
new_shape shape_j "x.. xxx"
new_shape shape_i "xxxx"
new_shape shape_t ".x. xxx"
new_shape shape_l "..x xxx"
new_shape shape_s ".xx xx."

clear

render_shape shape_o 10 10
render_shape shape_z 10 15 1
render_shape shape_j 10 20 2
render_shape shape_i 10 25
render_shape shape_t 10 31 3
render_shape shape_l 10 36 6
render_shape shape_s 10 41
