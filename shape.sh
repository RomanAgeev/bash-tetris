#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh

init_shape() {
    local string="${1:?}"

    local lines
    local IFS
    IFS=' ' read -r -a lines <<< "$string"

    SHAPE_WIDTH=
    for line in "${lines[@]}"; do
        local line_width="${#line}"
        if [ $line_width -ne ${SHAPE_WIDTH:=$line_width} ]; then
            printf "Shape \"%s\"is not rectangular\n" "$string" >&2
            return 1
        fi
    done

    SHAPE_HEIGHT="${#lines[@]}"
    SHAPE_LENGTH=$(( $SHAPE_WIDTH * $SHAPE_HEIGHT ))

    # 0-rotation format
    local shape_format_0; _shape__get_format shape_format_0 "${lines[@]}"
    SHAPE_FORMAT_0=("${shape_format_0[@]}")

    # 90-rotation format
    local shape_lines_1; _shape__get_lines_1 shape_lines_1 "$SHAPE_WIDTH" "$SHAPE_HEIGHT" "${lines[@]}"
    local shape_format_1; _shape__get_format shape_format_1 "${shape_lines_1[@]}"
    SHAPE_FORMAT_1=("${shape_format_1[@]}")

    # 180-rotation format
    local shape_lines_2; _shape__get_lines_2 shape_lines_2 "$SHAPE_WIDTH" "$SHAPE_HEIGHT" "${lines[@]}"
    local shape_format_2; _shape__get_format shape_format_2 "${shape_lines_2[@]}"
    SHAPE_FORMAT_2=("${shape_format_2[@]}")

    # 270-rotation format
    local shape_lines_3; _shape__get_lines_3 shape_lines_3 "$SHAPE_WIDTH" "$SHAPE_HEIGHT" "${lines[@]}"
    local shape_format_3; _shape__get_format shape_format_3 "${shape_lines_3[@]}"
    SHAPE_FORMAT_3=("${shape_format_3[@]}")
}

shape__get_actual_width() {
    local rotation=$(( ${1:?} % 4 ))
    local result="${2:?}"

    local _actual_width;
    [ $(( $rotation % 2 )) -eq 0 ] && _actual_width="$SHAPE_WIDTH" || _actual_width="$SHAPE_HEIGHT"

    eval "$result=\$_actual_width"
}

shape__get_actual_height() {
    local rotation=$(( ${1:?} % 4 ))
    local result="${2:?}"

    local _actual_height;
    [ $(( $rotation % 2 )) -eq 0 ] && _actual_height="$SHAPE_HEIGHT" || _actual_height="$SHAPE_WIDTH"

    eval "$result=\$_actual_height"
}

shape__get_canvas() {
    local row="${1:?}"
    local col="${2:?}"
    local rotation=$(( ${3:?} % 4 ))
    local color="${4:?}"
    local result="${5:-shape_canvas}"

    eval "local format=( \"\${SHAPE_FORMAT_$rotation[@]}\" )"

    canvas__new canvas
    canvas__set_foreground canvas "$color"
    canvas__cursor_at canvas "$row" "$col"
    for line in "${format[@]}"; do
        canvas__add_format_line canvas "$line"
    done

    eval "$result=canvas"
}

_shape__get_format() {
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

_shape__get_lines_1() {
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

_shape__get_lines_2() {
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

_shape__get_lines_3() {
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
