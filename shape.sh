#!/bin/bash

new_shape() {
    local this="${1:?}"
    local string="${2:?}"

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

    fill_array "$length" "G"

    set_field "$this" width "$width"
    set_field "$this" height "$height"
    set_field "$this" format "$format"
    set_field "$this" array "${__FILL_ARRAY[@]}"
}

render_shape() {
    local this="${1:?}"

    local format; eval "format=\$${this}__format"
    local array; eval "array=( \"\${${this}__array[@]}\" )"

    printf "$format" "${array[@]}"
}