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

    init_shape_format 0 "${lines[@]}"
    init_shape_format 1 "${lines[@]}"
    init_shape_format 2 "${lines[@]}"
    init_shape_format 3 "${lines[@]}"
}

init_shape_actual_size() {
    [ $(( $SHAPE_ROTATION % 2 )) -eq 0 ] && {
        SHAPE_ACTUAL_WIDTH=$SHAPE_WIDTH
        SHAPE_ACTUAL_HEIGHT=$SHAPE_HEIGHT
    } || {
        SHAPE_ACTUAL_WIDTH=$SHAPE_HEIGHT
        SHAPE_ACTUAL_HEIGHT=$SHAPE_WIDTH
    }
}

init_shape_canvas() {
    eval "local format=( \"\${SHAPE_FORMAT_$SHAPE_ROTATION[@]}\" )"

    init_canvas
    set_canvas_foreground "$SHAPE_COLOR"
    set_canvas_cursor_at "$SHAPE_ROW" "$SHAPE_COL"
    for line in "${format[@]}"; do
        add_canvas_format_line "$line"
    done

    SHAPE_CANVAS=$CANVAS
}

init_shape_format() {
    local rotation="${1:?}"

    shift 1

    eval "init_shape_lines_$rotation \"\$@\""
    eval "local lines=( \"\${SHAPE_LINES_$rotation[@]}\" )"

    local format=()
    for line in "${lines[@]}"; do
        local line_format="${line//[^.]/%s}"
        line_format="${line_format//./ %.0s}"
        format+=( "$line_format" )
    done

    eval "SHAPE_FORMAT_$rotation=( \"\${format[@]}\" )"
}

init_shape_lines_0() {
    SHAPE_LINES_0=( $@ )
}

init_shape_lines_1() {
    local lines=( $@ )

    SHAPE_LINES_1=()
    for (( i=0; i<$SHAPE_WIDTH; i++ )); do
        local line=""
        for (( j=$SHAPE_HEIGHT-1; j>=0; j-- )); do
            line=$line"${lines[$j]:$i:1}"
        done
        SHAPE_LINES_1+=( "$line" )
    done
}

init_shape_lines_2() {
    local lines=( $@ )

    SHAPE_LINES_2=()
    for (( j=$SHAPE_HEIGHT-1; j>=0; j-- )); do
        local line=""
        for (( i=$SHAPE_WIDTH-1; i>=0; i-- )); do
            line=$line"${lines[$j]:$i:1}"
        done
        SHAPE_LINES_2+=( "$line" )
    done
}

init_shape_lines_3() {
    local lines=( $@ )

    SHAPE_LINES_3=()
    for (( i=$SHAPE_WIDTH-1; i>=0; i-- )); do
        local line=""
        for (( j=0; j<$SHAPE_HEIGHT;j++ )); do
            line=$line"${lines[$j]:$i:1}"
        done
        SHAPE_LINES_3+=( "$line" )
    done
}
