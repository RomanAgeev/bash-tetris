#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh
source ./shape.sh

init_shape_view() {
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

shape_view__get_height() {
    local result="${1:?}"

    local actual_height; shape__get_actual_height "$SHAPE_ROTATION" actual_height

    eval "$result=\$actual_height"
}

shape_view__get_width() {
    local result="${1:?}"

    local actual_width; shape__get_actual_width "$SHAPE_ROTATION" actual_width

    eval "$result=\$actual_width"
}

shape_view__enable_auto_render() {
    [ $SHAPE_RENDER_ENABLED -eq 0 ] || {
        SHAPE_RENDER_ENABLED=0
        _shape_view__render
    }
}

shape_view__disable_auto_render() {
    SHAPE_RENDER_ENABLED=1
}

shape_view__move_at() {
    SHAPE_ROW=${1:?}
    SHAPE_COL=${2:?}
    _shape_view__render
}

shape_view__move_left() {
    SHAPE_COL=$(( $SHAPE_COL - 1 ))
    _shape_view__render
}

shape_view__move_right() {
    SHAPE_COL=$(( $SHAPE_COL + 1 ))
    _shape_view__render
}

shape_view__move_down() {
    SHAPE_ROW=$(( $SHAPE_ROW + 1 ))
    _shape_view__render
}

shape_view__rotate_right() {
    SHAPE_ROTATION=$(( ($SHAPE_ROTATION + 1) % 4 ))
    _shape_view__render
}

shape_view__set_color() {
    SHAPE_COLOR="${1:?}"
    _shape_view__render
}

_shape_view__render() {
    [ $SHAPE_RENDER_ENABLED -eq 0 ] || return 0

    if [ -n "$SHAPE_CANVAS" ]; then
        canvas__render "$SHAPE_CANVAS" "${SHAPE_SPACES[@]}"
        canvas__free "$SHAPE_CANVAS"
    fi

    init_shape_canvas
    canvas__render "$SHAPE_CANVAS" "${SHAPE_PLACEHOLDERS[@]}"
}
