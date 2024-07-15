#!/bin/bash

set -euo pipefail

source ./utils/_main.sh

_render_shape() {
    local shape="${1:?}"

    local width="${shape%% *}"
    if ! valid_int "$width"; then
        printf "ERROR\n" >&2
        return 1
    fi

    local body="${shape#* }"
    local length="${#body}"

    if [ $(( $length % $width )) -ne 0 ]; then
        printf "ERROR_2\n" >&2
        return 1
    fi

    local height=$(( $length / $width ))

    local format
    local line_format
    local i=0
    for (( i=0; i<$height; i++ )); do
        local offset=$(( $i * $width ))
        local line="${body:$offset:$width}"
        line_format="${line//[^.]/%s}"
        line_format="${line_format//./ %.0s}"
        format="$format$line_format\n"
    done

    local char='O'
    local arr=()
    while [ ${#arr[@]} -lt $length ]; do
        arr+=( $char )
    done

    printf "$format" "${arr[@]}"
}

_render_shape "2 ****"
echo
_render_shape "3 **..**"
echo
_render_shape "3 *..***"
echo
_render_shape "4 ****"
echo
_render_shape "3 .*.***"
echo
_render_shape "3 ..****"
echo
_render_shape "3 .****."

