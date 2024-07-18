#!/bin/bash

set -euo pipefail

source ./shape.sh
source ./shape_view.sh

set_shape_default_placeholder O

# new_shape shape_o "xx xx"
# new_shape shape_z "xx. .xx"
# new_shape shape_j "x.. xxx"
# new_shape shape_i "xxxx"
# new_shape shape_l "..x xxx"
# new_shape shape_s ".xx xx."

new_shape shape_t ".x. xxx"
new_shape_view shape_view_t shape_t

clear

move_shape_view_at shape_view_t 30 30

for i in {1..10}; do
    sleep 0.1
    move_shape_view_up shape_view_t
done

for i in {1..10}; do
    sleep 0.1
    move_shape_view_right shape_view_t
done

for i in {1..10}; do
    sleep 0.1
    move_shape_view_down shape_view_t
done

for i in {1..10}; do
    sleep 0.1
    move_shape_view_left shape_view_t
done

for i in {1..10}; do
    sleep 0.5
    rotate_shape_view_right shape_view_t
done

for i in {1..10}; do
    sleep 0.5
    rotate_shape_view_left shape_view_t
done
