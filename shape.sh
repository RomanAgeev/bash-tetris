#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh

new_class shape

get_shape_length() {
    local this="${1:?}"
    local result="${2:-shape_length}"

    local length; get_shape_field "$this" length
    eval "$result=\$length"
}

_shape_format() {
    __SHAPE_FORMAT=()
    for line in "$@"; do
        local line_format="${line//[^.]/%s}"
        line_format="${line_format//./ %.0s}"
        __SHAPE_FORMAT+=( "$line_format" )
    done
}

_shape_lines_1() {
    local width="${1:?}"
    local height="${2:?}"

    shift 2

    local lines=( $@ )

    __SHAPE_LINES_1=()
    for (( i=0; i<$width; i++ )); do
        local line=""
        for (( j=$height-1; j>=0; j-- )); do
            line=$line"${lines[$j]:$i:1}"
        done
        __SHAPE_LINES_1+=( "$line" )
    done
}

_shape_lines_2() {
    local width="${1:?}"
    local height="${2:?}"

    shift 2

    local lines=( $@ )

    __SHAPE_LINES_2=()
    for (( j=$height-1; j>=0; j-- )); do
        local line=""
        for (( i=$width-1; i>=0; i-- )); do
            line=$line"${lines[$j]:$i:1}"
        done
        __SHAPE_LINES_2+=( "$line" )
    done
}

_shape_lines_3() {
    local width="${1:?}"
    local height="${2:?}"

    shift 2

    local lines=( $@ )

    __SHAPE_LINES_3=()
    for (( i=$width-1; i>=0; i-- )); do
        local line=""
        for (( j=0; j<$height;j++ )); do
            line=$line"${lines[$j]:$i:1}"
        done
        __SHAPE_LINES_3+=( "$line" )
    done
}

new_shape() {
    local this="${1:?}"
    local string="${2:?}"

    local lines;
    IFS=' ' read -r -a lines <<< "$string"

    local width
    for line in "${lines[@]}"; do
        local line_width="${#line}"
        if [ $line_width -ne ${width:=$line_width} ]; then
            printf "Shape \"%s\"is not rectangular\n" "$string" >&2
            return 1
        fi
    done

    local height="${#lines[@]}"
    local length=$(( $width * $height ))

    # 0-rotation format
    _shape_format "${lines[@]}"
    set_shape_array_field "$this" format_0 "${__SHAPE_FORMAT[@]}"

    # 90-rotation format
    _shape_lines_1 "$width" "$height" "${lines[@]}"
    _shape_format "${__SHAPE_LINES_1[@]}"
    set_shape_array_field "$this" format_1 "${__SHAPE_FORMAT[@]}"

    # 180-rotation format
    _shape_lines_2 "$width" "$height" "${lines[@]}"
    _shape_format "${__SHAPE_LINES_2[@]}"
    set_shape_array_field "$this" format_2 "${__SHAPE_FORMAT[@]}"

    # 270-rotation format
    _shape_lines_3 "$width" "$height" "${lines[@]}"
    _shape_format "${__SHAPE_LINES_3[@]}"
    set_shape_array_field "$this" format_3 "${__SHAPE_FORMAT[@]}"

    set_shape_field "$this" width "$width"
    set_shape_field "$this" height "$height"
    set_shape_field "$this" length "$length"
}

shape_canvas() {
    local this="${1:?}"
    local row="${2:?}"
    local col="${3:?}"
    local rotation=$(( ${4:-0} % 4 ))

    local format_field="format_${rotation}"

    eval "local $format_field; get_shape_array_field \$this $format_field"
    eval "local format=( \"\${$format_field[@]}\" )"

    local canvas="${this}_canvas"

    new_canvas "$canvas"
    cursor_at "$canvas" "$row" "$col"

    for line in "${format[@]}"; do
        add_format_line "$canvas" "$line"
    done

    __SHAPE_CANVAS="$canvas"
}
