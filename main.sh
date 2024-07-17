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

render_shape shape_o; echo
render_shape shape_z; echo
render_shape shape_j; echo
render_shape shape_i; echo
render_shape shape_t; echo
render_shape shape_l; echo
render_shape shape_s; echo
