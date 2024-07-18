#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh

shape_classname=shape

set_shape_default_placeholder() {
    set_field "$shape_classname" default_placeholder "${1:?}"
}

get_shape_default_placeholder() {
    get_field "$shape_classname" default_placeholder
}

new_shape() {
    local this="${1:?}"
    local string="${2:?}"
    local default_placeholder; get_shape_default_placeholder
    local placeholder="${3:-$default_placeholder}"

    local lines;
    IFS=' ' read -r -a lines <<< "$string"

    local width
    local format=()
    for line in "${lines[@]}"; do
        local line_width="${#line}"
        if [ $line_width -ne ${width:=$line_width} ]; then
            printf "Shape \"%s\"is not rectangular\n" "$string" >&2
            return 1
        fi
        local line_format="${line//[^.]/%s}"
        line_format="${line_format//./ %.0s}"
        format+=( "$line_format" )
    done

    local height="${#lines[@]}"

    fill_array $(( $width * $height )) "$placeholder"

    set_field "$this" width "$width"
    set_field "$this" height "$height"
    set_array_field "$this" format "${format[@]}"
    set_array_field "$this" array "${__FILL_ARRAY[@]}"
}

render_shape() {
    local this="${1:?}"
    local row="${2:?}"
    local col="${3:?}"

    local format; get_array_field "$this" format
    local array; get_array_field "$this" array

    local canvas="${this}_canvas"

    new_canvas "$canvas"
    cursor_at "$canvas" "$row" "$col"

    for line in "${format[@]}"; do
        add_format_line "$canvas" "$line"
    done

    render_canvas "$canvas" "${array[@]}"
}

set_shape_default_placeholder X
