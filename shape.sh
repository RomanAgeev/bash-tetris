#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh

new_class shape

get_shape_length() {
    local this="${1:?}"
    local result="${2:-shape_length}"

    local length; get_shape_field "$this" length
    eval "$result=\"\$length\""
}

_get_shape_format() {
    local result="${1:?}"

    shift 1

    local format=()
    for line in "$@"; do
        local line_format="${line//[^.]/%s}"
        line_format="${line_format//./ %.0s}"
        format+=( "$line_format" )
    done

    eval "$result=( \"\${format[@]}\" )"
}

_get_shape_lines_1() {
    local result="${1:?}"
    local width="${2:?}"
    local height="${3:?}"

    shift 3

    local lines=( $@ )

    local shape_lines=()
    for (( i=0; i<$width; i++ )); do
        local line=""
        for (( j=$height-1; j>=0; j-- )); do
            line=$line"${lines[$j]:$i:1}"
        done
        shape_lines+=( "$line" )
    done

    eval "$result=( \"\${shape_lines[@]}\" )"
}

_get_shape_lines_2() {
    local result="${1:?}"
    local width="${2:?}"
    local height="${3:?}"

    shift 3

    local lines=( $@ )

    local shape_lines=()
    for (( j=$height-1; j>=0; j-- )); do
        local line=""
        for (( i=$width-1; i>=0; i-- )); do
            line=$line"${lines[$j]:$i:1}"
        done
        shape_lines+=( "$line" )
    done

    eval "$result=( \"\${shape_lines[@]}\" )"
}

_get_shape_lines_3() {
    local result="${1:?}"
    local width="${2:?}"
    local height="${3:?}"

    shift 3

    local lines=( $@ )

    local shape_lines=()
    for (( i=$width-1; i>=0; i-- )); do
        local line=""
        for (( j=0; j<$height;j++ )); do
            line=$line"${lines[$j]:$i:1}"
        done
        shape_lines+=( "$line" )
    done

    eval "$result=( \"\${shape_lines[@]}\" )"
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
    local shape_format_0; _get_shape_format shape_format_0 "${lines[@]}"
    set_shape_array_field "$this" format_0 "${shape_format_0[@]}"

    # 90-rotation format
    local shape_lines_1; _get_shape_lines_1 shape_lines_1 "$width" "$height" "${lines[@]}"
    local shape_format_1; _get_shape_format shape_format_1 "${shape_lines_1[@]}"
    set_shape_array_field "$this" format_1 "${shape_format_1[@]}"

    # 180-rotation format
    local shape_lines_2; _get_shape_lines_2 shape_lines_2 "$width" "$height" "${lines[@]}"
    local shape_format_2; _get_shape_format shape_format_2 "${shape_lines_2[@]}"
    set_shape_array_field "$this" format_2 "${shape_format_2[@]}"

    # 270-rotation format
    local shape_lines_3; _get_shape_lines_3 shape_lines_3 "$width" "$height" "${lines[@]}"
    local shape_format_3; _get_shape_format shape_format_3 "${shape_lines_3[@]}"
    set_shape_array_field "$this" format_3 "${shape_format_3[@]}"

    set_shape_field "$this" width "$width"
    set_shape_field "$this" height "$height"
    set_shape_field "$this" length "$length"
}

build_shape_canvas() {
    local this="${1:?}"
    local row="${2:?}"
    local col="${3:?}"
    local rotation=$(( ${4:-0} % 4 ))
    local result="${5:-shape_canvas}"

    local format_field="format_${rotation}"

    eval "local $format_field; get_shape_array_field \$this $format_field"
    eval "local format=( \"\${$format_field[@]}\" )"

    local canvas; _shape_field_name "$this" canvas

    new_canvas "$canvas"
    cursor_at "$canvas" "$row" "$col"

    for line in "${format[@]}"; do
        add_format_line "$canvas" "$line"
    done

    eval "$result=\"\$canvas\"" 
}
