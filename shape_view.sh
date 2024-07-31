#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh
source ./shape.sh

new_class shape_view

shape_view__set_placeholder() {
    __set_shape_view_static_field placeholder "${1:?}"
}

shape_view__get_placeholder() {
    get_shape_view_static_field placeholder
}

shape_view__new() {
    local this="${1:?}"
    local shape="${2:?}"

    __init_shape_view "$this"

    __set_shape_view_field "$this" shape "$shape"
    __set_shape_view_field "$this" canvas
    __set_shape_view_field "$this" row 0
    __set_shape_view_field "$this" col 0
    __set_shape_view_field "$this" rotation 0
    __set_shape_view_field "$this" color "$WHITE"

    __set_shape_view_field "$this" render_enabled 1

    local shape_length; shape__get_length "$shape"

    local placeholder; shape_view__get_placeholder
    local placeholders; fill_array placeholders "$shape_length" "$placeholder"
    __set_shape_view_array_field "$this" placeholders "${placeholders[@]}"
    local spaces; fill_array spaces "$shape_length"
    __set_shape_view_array_field "$this" spaces "${spaces[@]}"
}

shape_view__free() {
    local this="${1:?}"

    __exist_shape_view "$this" && {
        local shape; __get_shape_view_field "$this" shape
        shape__free "$shape"

        local canvas; __get_shape_view_field "$this" canvas
        canvas__free "$canvas"

        __free_shape_view "$this"
    }
}

shape_view__get_col() {
    local this="${1:?}"
    local result="${2:?}"

    local col; __get_shape_view_field "$this" col

    eval "$result=\$col"
}

shape_view__get_row() {
    local this="${1:?}"
    local result="${2:?}"

    local row; __get_shape_view_field "$this" row

    eval "$result=\$row"
}

shape_view__get_height() {
    local this="${1:?}"
    local result="${2:?}"

    local shape; __get_shape_view_field "$this" shape
    local rotation; __get_shape_view_field "$this" rotation
    local actual_height; shape__get_actual_height "$shape" "$rotation" actual_height

    eval "$result=\$actual_height"
}

shape_view__get_width() {
    local this="${1:?}"
    local result="${2:?}"

    local shape; __get_shape_view_field "$this" shape
    local rotation; __get_shape_view_field "$this" rotation
    local actual_width; shape__get_actual_width "$shape" "$rotation" actual_width

    eval "$result=\$actual_width"
}

shape_view__enable_auto_render() {
    local this="${1:?}"

    _shape_view__is_render_enabled || {
        __set_shape_view_field "$this" render_enabled 0
        _shape_view__render "$this"
    }
}

shape_view__disable_auto_render() {
    local this="${1:?}"

    __set_shape_view_field "$this" render_enabled 1
}

shape_view__move_at() {
    local this="${1:?}"
    local row="${2:?}"
    local col="${3:?}"

    __set_shape_view_field "$this" row "$row"
    __set_shape_view_field "$this" col "$col"

    _shape_view__render "$this"
}

shape_view__move_left() {
    local this="${1:?}"
    local step="${2:-1}"

    local col; __get_shape_view_field "$this" col
    __set_shape_view_field "$this" col $(( $col - $step ))

    _shape_view__render "$this"
}

shape_view__move_right() {
    local this="${1:?}"
    local step="${2:-1}"

    local col; __get_shape_view_field "$this" col
    __set_shape_view_field "$this" col $(( $col + $step ))

    _shape_view__render "$this"
}

shape_view__move_down() {
    local this="${1:?}"
    local step="${2:-1}"

    local row; __get_shape_view_field "$this" row
    __set_shape_view_field "$this" row $(( $row + $step ))

    _shape_view__render "$this"
}

shape_view__rotate_right() {
    local this="${1:?}"

    local rotation; __get_shape_view_field "$this" rotation
    __set_shape_view_field "$this" rotation $(( ($rotation + 1) % 4 ))

    _shape_view__render "$this"
}

shape_view__set_color() {
    local this="${1:?}"
    local color="${2:?}"

    __set_shape_view_field "$this" color "$color"

    _shape_view__render "$this"
}

_shape_view__is_render_enabled() {
    local render_enabled; __get_shape_view_field "$this" render_enabled
    return $render_enabled
}

_shape_view__render() {
    local this="${1:?}"

    local render_enabled; __get_shape_view_field "$this" render_enabled
    _shape_view__is_render_enabled || return 0

    local canvas; __get_shape_view_field "$this" canvas
    local shape; __get_shape_view_field "$this" shape
    local row; __get_shape_view_field "$this" row
    local col; __get_shape_view_field "$this" col
    local rotation; __get_shape_view_field "$this" rotation
    local color; __get_shape_view_field "$this" color
    local placeholders; __get_shape_view_array_field "$this" placeholders
    local spaces; __get_shape_view_array_field "$this" spaces

    if [ -n "$canvas" ]; then
        canvas__render "$canvas" "${spaces[@]}"
        canvas__free "$canvas"
    fi

    local shape_canvas; shape__get_canvas "$shape" "$row" "$col" "$rotation" "$color"
    canvas__render "$shape_canvas" "${placeholders[@]}"

    __set_shape_view_field "$this" canvas "$shape_canvas"
}

shape_view__set_placeholder X
