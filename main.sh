#!/bin/bash

set -euo pipefail

source ./constants.sh
source ./shape.sh

new_shape shape_o "2 xxxx" "$shape_placeholder"
new_shape shape_z "3 xx..xx" "$shape_placeholder"
new_shape shape_j "3 x..xxx" "$shape_placeholder"
new_shape shape_i "4 xxxx" "$shape_placeholder"
new_shape shape_t "3 .x.xxx" "$shape_placeholder"
new_shape shape_l "3 ..xxxx" "$shape_placeholder"
new_shape shape_s "3 .xxxx." "$shape_placeholder"

render_shape shape_o; echo
render_shape shape_z; echo
render_shape shape_j; echo
render_shape shape_i; echo
render_shape shape_t; echo
render_shape shape_l; echo
render_shape shape_s; echo
