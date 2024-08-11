#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh

init_shape() {
    local string="${1:?}"
    local color="${2:?}"
    local row="${3:?}"
    local col="${4:?}"
    local placeholder="${5:?}"

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
    SHAPE_ROW=$row
    SHAPE_COL=$col
    SHAPE_ROTATION=0
    SHAPE_COLOR="$color"
    SHAPE_PLACEHOLDER="$placeholder"
    local placeholders; fill_array placeholders "$SHAPE_LENGTH" "$SHAPE_PLACEHOLDER"
    SHAPE_PLACEHOLDERS=("${placeholders[@]}")
    local spaces; fill_array spaces "$SHAPE_LENGTH"
    SHAPE_SPACES=("${spaces[@]}")
}

render_shape() {
    clear_shape

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

clear_shape() {
    if [ -n "$SHAPE_CANVAS" ]; then
        CANVAS="$SHAPE_CANVAS"
        render_canvas "${SHAPE_SPACES[@]}"
    fi
}

init_shape_format() {
    local rotation="${1:?}"

    shift 1

    eval "init_shape_lines_$rotation \"\$@\""
    eval "local lines=( \"\${SHAPE_LINES_$rotation[@]}\" )"

    local format=()
    for line in "${lines[@]}"; do
        local line_format=
        local line_length=""${#line}
        while [ $line_length -gt 0 ]; do
            local empty_tail="${line#+(.)}"
            local empty_length=$(( $line_length - ${#empty_tail} ))

            [ $empty_length -gt 0 ] && {
                local empty;
                printf -v empty "$CUR_RIGHT_N" "$empty_length"
                line_format="$line_format$empty"
                line_length=${#empty_tail}
                line="$empty_tail"
            }

            local full_tail="${line#+([^.])}"
            local full_length=$(( $line_length - ${#full_tail} ))

            [ $full_length -gt 0 ] && {
                local full="${line:0:$full_length}"
                line_format="$line_format${full//[^.]/%s}"
                line_length=${#full_tail}
                line="$full_tail"
            }
        done
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
