#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh
source ./shape.sh

new_class shape_view

set_shape_view_default_placeholder() {
    __set_shape_view_static_field default_placeholder "${1:?}"
}

get_shape_view_default_placeholder() {
    get_shape_view_static_field default_placeholder
}

new_shape_view() {
    local this="${1:?}"
    local shape="${2:?}"
    local default_placeholder; get_shape_view_default_placeholder
    local placeholder="${3:-$default_placeholder}"

    __set_shape_view_field "$this" shape "$shape"
    __set_shape_view_field "$this" canvas
    __set_shape_view_field "$this" row 0
    __set_shape_view_field "$this" col 0
    __set_shape_view_field "$this" rotation 0
    __set_shape_view_field "$this" color "$WHITE"

    __set_shape_view_field "$this" render_enabled "$NO"

    local shape_length; get_shape_length "$shape"

    local placeholders; fill_array placeholders "$shape_length" "$placeholder"
    __set_shape_view_array_field "$this" placeholders "${placeholders[@]}"
    local spaces; fill_array spaces "$shape_length"
    __set_shape_view_array_field "$this" spaces "${spaces[@]}"
}

get_shape_view_col() {
    local this="${1:?}"
    local result="${2:?}"

    local col; __get_shape_view_field "$this" col

    eval "$result=\$col"
}

get_shape_view_row() {
    local this="${1:?}"
    local result="${2:?}"

    local col; __get_shape_view_field "$this" row

    eval "$result=\$row"
}

get_shape_view_height() {
    local this="${1:?}"
    local result="${2:?}"

    local shape; __get_shape_view_field "$this" shape
    local rotation; __get_shape_view_field "$this" rotation
    local actual_height; get_shape_actual_height "$shape" "$rotation" actual_height

    eval "$result=\$actual_height"
}

_render_shape_view() {
    local this="${1:?}"

    local render_enabled; __get_shape_view_field "$this" render_enabled
    [ "$render_enabled" == "$YES" ] || return 0

    local canvas; __get_shape_view_field "$this" canvas
    local shape; __get_shape_view_field "$this" shape
    local row; __get_shape_view_field "$this" row
    local col; __get_shape_view_field "$this" col
    local rotation; __get_shape_view_field "$this" rotation
    local color; __get_shape_view_field "$this" color
    local placeholders; __get_shape_view_array_field "$this" placeholders
    local spaces; __get_shape_view_array_field "$this" spaces

    if [ -n "$canvas" ]; then
        render_canvas "$canvas" "${spaces[@]}"
    fi

    local shape_canvas; build_shape_canvas "$shape" "$row" "$col" "$rotation" "$color"
    render_canvas "$shape_canvas" "${placeholders[@]}"

    __set_shape_view_field "$this" canvas "$shape_canvas"
}

enabled_shape_view_render() {
    local this="${1:?}"

    local render_enabled; __get_shape_view_field "$this" render_enabled
    [ "$render_enabled" == "$NO" ] && {
        __set_shape_view_field "$this" render_enabled "$YES"
        _render_shape_view "$this"
    }
}

disable_shape_view_render() {
    local this="${1:?}"

    local render_enabled; __get_shape_view_field "$this" render_enabled
    [ "$render_enabled" == "$YES" ] && __set_shape_view_field "$this" render_enabled "$NO"
}

move_shape_view_at() {
    local this="${1:?}"
    local row="${2:?}"
    local col="${3:?}"

    __set_shape_view_field "$this" row "$row"
    __set_shape_view_field "$this" col "$col"

    _render_shape_view "$this"
}

move_shape_view_left() {
    local this="${1:?}"
    local step="${2:-1}"

    local col; __get_shape_view_field "$this" col
    __set_shape_view_field "$this" col $(( $col - $step ))

    _render_shape_view "$this"
}

move_shape_view_right() {
    local this="${1:?}"
    local step="${2:-1}"

    local col; __get_shape_view_field "$this" col
    __set_shape_view_field "$this" col $(( $col + $step ))

    _render_shape_view "$this"
}

move_shape_view_up() {
    local this="${1:?}"
    local step="${2:-1}"

    local row; __get_shape_view_field "$this" row
    __set_shape_view_field "$this" row $(( $row - $step ))

    _render_shape_view "$this"
}

move_shape_view_down() {
    local this="${1:?}"
    local step="${2:-1}"

    local row; __get_shape_view_field "$this" row
    __set_shape_view_field "$this" row $(( $row + $step ))

    _render_shape_view "$this"
}

rotate_shape_view_right() {
    local this="${1:?}"

    local rotation; __get_shape_view_field "$this" rotation
    __set_shape_view_field "$this" rotation $(( ($rotation + 1) % 4 ))

    _render_shape_view "$this"
}

rotate_shape_view_left() {
    local this="${1:?}"

    local rotation; __get_shape_view_field "$this" rotation
    rotation=$(( $rotation - 1 ))
    [ $rotation -lt 0 ] && rotation=$(( 4 + $rotation ))
    __set_shape_view_field "$this" rotation $rotation

    _render_shape_view "$this"
}

set_shape_view_color() {
    local this="${1:?}"
    local color="${2:?}"

    __set_shape_view_field "$this" color "$color"

    _render_shape_view "$this"
}

set_shape_view_default_placeholder X
