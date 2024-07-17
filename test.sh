#!/bin/bash

set -euo pipefail

source ./canvas.sh

clear

new_canvas shapes
cursor_at shapes 20 30
add_format shapes "%s-1-%s" Roman Ageev
add_string shapes Rita
add_format shapes "%s_%s"
render_canvas shapes Rita Ageeva
