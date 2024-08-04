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

    SHAPE_CANVAS=
    SHAPE_ROW=0
    SHAPE_COL=0
    SHAPE_ROTATION=0
    SHAPE_COLOR="$WHITE"
    SHAPE_RENDER_ENABLED=1
    SHAPE_PLACEHOLDER=O
    local placeholders; fill_array placeholders "$SHAPE_LENGTH" "$SHAPE_PLACEHOLDER"
    SHAPE_PLACEHOLDERS=("${placeholders[@]}")
    local spaces; fill_array spaces "$SHAPE_LENGTH"
    SHAPE_SPACES=("${spaces[@]}")
}

enable_shape_auto_render() {
    [ $SHAPE_RENDER_ENABLED -eq 0 ] || {
        SHAPE_RENDER_ENABLED=0
        _shape_view__render
    }
}

disable_shape_auto_render() {
    SHAPE_RENDER_ENABLED=1
}

move_shape_at() {
    SHAPE_ROW=${1:?}
    SHAPE_COL=${2:?}
    _shape_view__render
}

move_shape_left() {
    SHAPE_COL=$(( $SHAPE_COL - 1 ))
    _shape_view__render
}

move_shape_right() {
    SHAPE_COL=$(( $SHAPE_COL + 1 ))
    _shape_view__render
}

move_shape_down() {
    SHAPE_ROW=$(( $SHAPE_ROW + 1 ))
    _shape_view__render
}

rotate_shape() {
    SHAPE_ROTATION=$(( ($SHAPE_ROTATION + 1) % 4 ))
    _shape_view__render
}

set_shape_color() {
    SHAPE_COLOR="${1:?}"
    _shape_view__render
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

_shape_view__render() {
    [ $SHAPE_RENDER_ENABLED -eq 0 ] || return 0

    if [ -n "$SHAPE_CANVAS" ]; then
        CANVAS="$SHAPE_CANVAS"
        render_canvas "${SHAPE_SPACES[@]}"
    fi

    eval "local format=( \"\${SHAPE_FORMAT_$SHAPE_ROTATION[@]}\" )"

    init_canvas
    set_canvas_foreground "$SHAPE_COLOR"
    set_canvas_cursor_at "$SHAPE_ROW" "$SHAPE_COL"
    for line in "${format[@]}"; do
        add_canvas_format_line "$line"
    done

    render_canvas "${SHAPE_PLACEHOLDERS[@]}"

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
