#!/bin/bash

new_shape() {
    local name="${1:?}"
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

    eval "${name}__width=\$width"
    eval "${name}__height=\$height"
    eval "${name}__format=\"\$format\""
    eval "${name}__array=( \"\${__FILL_ARRAY[@]}\" )"
}

render_shape() {
    local name="${1:?}"

    local format; eval "format=\$${name}__format"
    local array; eval "array=( \"\${${name}__array[@]}\" )"

    printf "$format" "${array[@]}"
}