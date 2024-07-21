#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh
source ./shape.sh

new_class shape_view

set_shape_view_default_placeholder() {
    set_shape_view_static_field default_placeholder "${1:?}"
}

get_shape_view_default_placeholder() {
    get_shape_view_static_field default_placeholder
}

new_shape_view() {
    local this="${1:?}"
    local shape="${2:?}"
    local default_placeholder; get_shape_view_default_placeholder
    local placeholder="${3:-$default_placeholder}"

    set_shape_view_field "$this" shape "$shape"
    set_shape_view_field "$this" canvas
    set_shape_view_field "$this" row 0
    set_shape_view_field "$this" col 0
    set_shape_view_field "$this" rotation 0

    local shape_length; get_shape_length "$shape"

    fill_array "$shape_length" "$placeholder"
    set_shape_view_array_field "$this" placeholders "${__FILL_ARRAY[@]}"
    fill_array "$shape_length"
    set_shape_view_array_field "$this" spaces "${__FILL_ARRAY[@]}"
}

_render_shape_view() {
    local this="${1:?}"

    local canvas; get_shape_view_field "$this" canvas
    local shape; get_shape_view_field "$this" shape
    local row; get_shape_view_field "$this" row
    local col; get_shape_view_field "$this" col
    local rotation; get_shape_view_field "$this" rotation
    local placeholders; get_shape_view_array_field "$this" placeholders
    local spaces; get_shape_view_array_field "$this" spaces

    if [ -n "$canvas" ]; then
        render_canvas "$canvas" "${spaces[@]}"
    fi

    shape_canvas "$shape" "$row" "$col" "$rotation"
    set_shape_view_field "$this" canvas "$__SHAPE_CANVAS"

    render_canvas "$__SHAPE_CANVAS" "${placeholders[@]}"
}

move_shape_view_at() {
    local this="${1:?}"
    local row="${2:?}"
    local col="${3:?}"

    set_shape_view_field "$this" row "$row"
    set_shape_view_field "$this" col "$col"

    _render_shape_view "$this"
}

move_shape_view_left() {
    local this="${1:?}"
    local step="${2:-1}"

    local col; get_shape_view_field "$this" col
    set_shape_view_field "$this" col $(( $col - $step ))

    _render_shape_view "$this"
}

move_shape_view_right() {
    local this="${1:?}"
    local step="${2:-1}"

    local col; get_shape_view_field "$this" col
    set_shape_view_field "$this" col $(( $col + $step ))

    _render_shape_view "$this"
}

move_shape_view_up() {
    local this="${1:?}"
    local step="${2:-1}"

    local row; get_shape_view_field "$this" row
    set_shape_view_field "$this" row $(( $row - $step ))

    _render_shape_view "$this"
}

move_shape_view_down() {
    local this="${1:?}"
    local step="${2:-1}"

    local row; get_shape_view_field "$this" row
    set_shape_view_field "$this" row $(( $row + $step ))

    _render_shape_view "$this"
}

rotate_shape_view_right() {
    local this="${1:?}"

    local rotation; get_shape_view_field "$this" rotation
    set_shape_view_field "$this" rotation $(( ($rotation + 1) % 4 ))

    _render_shape_view "$this"
}

rotate_shape_view_left() {
    local this="${1:?}"

    local rotation; get_shape_view_field "$this" rotation
    rotation=$(( $rotation - 1 ))
    [ $rotation -lt 0 ] && rotation=$(( 4 + $rotation ))
    set_shape_view_field "$this" rotation $rotation

    _render_shape_view "$this"
}

set_shape_view_default_placeholder X
