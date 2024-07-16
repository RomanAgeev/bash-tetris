#!/bin/bash

source ./utils/_main.sh

shape_classname=shape

set_shape_default_placeholder() {
    set_field "$shape_classname" default_placeholder "${1:?}"
}

get_shape_default_placeholder() {
    get_scalar_field "$shape_classname" default_placeholder
}

new_shape() {
    local this="${1:?}"
    local string="${2:?}"
    local default_placeholder; get_shape_default_placeholder
    local placeholder="${3:-$default_placeholder}"

    local width="${string%% *}"
    if ! valid_int "$width"; then
        printf "Shape width \"%s\" is not a number\n" "$width" >&2
        return 1
    fi

    local body="${string#* }"

    local length="${#body}"
    if [ $(( $length % $width )) -ne 0 ]; then
        printf "Shape is not rectangular\n" >&2
        return 1
    fi

    local height=$(( $length / $width ))

    local format
    for (( i=0; i<$height; i++ )); do
        local offset=$(( $i * $width ))
        local line="${body:$offset:$width}"
        local line_format="${line//[^.]/%s}"
        line_format="${line_format//./ %.0s}"
        format="$format$line_format\n"
    done

    fill_array "$length" "$placeholder"

    set_field "$this" width "$width"
    set_field "$this" height "$height"
    set_field "$this" format "$format"
    set_field "$this" array "${__FILL_ARRAY[@]}"
}

render_shape() {
    local this="${1:?}"

    local format; get_scalar_field "$this" format
    local array; get_array_field "$this" array

    printf "$format" "${array[@]}"
}

set_shape_default_placeholder X