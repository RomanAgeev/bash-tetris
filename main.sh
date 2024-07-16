#!/bin/bash

set -euo pipefail

source ./utils/_main.sh
source ./shape.sh

new_shape shape_o "2 xxxx"
new_shape shape_z "3 xx..xx"
new_shape shape_j "3 x..xxx"
new_shape shape_i "4 xxxx"
new_shape shape_t "3 .x.xxx"
new_shape shape_l "3 ..xxxx"
new_shape shape_s "3 .xxxx."

render_shape shape_o; echo
render_shape shape_z; echo
render_shape shape_j; echo
render_shape shape_i; echo
render_shape shape_t; echo
render_shape shape_l; echo
render_shape shape_s; echo

echo "$shape_z__width"
echo "$shape_z__height"
echo "$shape_z__format"
echo "${shape_z__array[@]}"
