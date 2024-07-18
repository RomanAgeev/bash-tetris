#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh
source ./shape.sh

shape_view_classname=shape_view

new_shape_view() {
    local this="${1:?}"
    local shape="${2:?}"

    set_field "$this" shape "$shape"
    set_field "$this" canvas
    set_field "$this" row 0
    set_field "$this" col 0
    set_field "$this" rotation 0
}

_render_shape_view() {
    local this="${1:?}"

    local canvas; get_field "$this" canvas
    local shape; get_field "$this" shape
    local row; get_field "$this" row
    local col; get_field "$this" col
    local rotation; get_field "$this" rotation

    if [ -n "$canvas" ]; then
        shape_spaces "$shape"
        render_canvas "$canvas" "${__SHAPE_SPACES[@]}"
    fi

    shape_canvas "$shape" "$row" "$col" "$rotation"
    shape_placeholders "$shape"

    render_canvas "$__SHAPE_CANVAS" "${__SHAPE_PLACEHOLDERS[@]}"

    set_field "$this" canvas "$__SHAPE_CANVAS"
}

move_shape_view_at() {
    local this="${1:?}"
    local row="${2:?}"
    local col="${3:?}"

    set_field "$this" row "$row"
    set_field "$this" col "$col"

    _render_shape_view "$this"
}

move_shape_view_left() {
    local this="${1:?}"
    local step="${2:-1}"

    local col; get_field "$this" col
    set_field "$this" col $(( $col - $step ))

    _render_shape_view "$this"
}

move_shape_view_right() {
    local this="${1:?}"
    local step="${2:-1}"

    local col; get_field "$this" col
    set_field "$this" col $(( $col + $step ))

    _render_shape_view "$this"
}

move_shape_view_up() {
    local this="${1:?}"
    local step="${2:-1}"

    local row; get_field "$this" row
    set_field "$this" row $(( $row - $step ))

    _render_shape_view "$this"
}

move_shape_view_down() {
    local this="${1:?}"
    local step="${2:-1}"

    local row; get_field "$this" row
    set_field "$this" row $(( $row + $step ))

    _render_shape_view "$this"
}

rotate_shape_view_right() {
    local this="${1:?}"

    local rotation; get_field "$this" rotation
    set_field "$this" rotation $(( ($rotation + 1) % 4 ))

    _render_shape_view "$this"
}

rotate_shape_view_left() {
    local this="${1:?}"

    local rotation; get_field "$this" rotation
    rotation=$(( $rotation - 1 ))
    [ $rotation -lt 0 ] && rotation=$(( 4 + $rotation ))
    set_field "$this" rotation $rotation

    _render_shape_view "$this"
}
