#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh
source ./shape_view.sh

WALL="|"
FLOOR="_"

init_stage() {
    ROW="${1:?}"
    COL="${2:?}"
    WIDTH="${3:?}"
    HEIGHT="${4:?}"
    BOTTOM=$(( $ROW + $HEIGHT ))
    RIGHT=$(( $COL + $WIDTH ))
    WIDTH_INNER=$(( $WIDTH - 1 ))
}

drop_shape() {
    init_shape_view "${1:?}"

    local start_col=$(( $COL + $WIDTH / 2 - 1 ))

    shape_view__move_at "$ROW" "$start_col"
}

is_shape_down() {
    local view_height; shape_view__get_height view_height
    local view_bottom=$(( $SHAPE_ROW + $view_height ))

    [ $view_bottom -ge $BOTTOM ]
}

is_shape_left() {
    [ $SHAPE_COL -le $(( $COL + 1 )) ]
}

is_shape_right() {
    local view_width; shape_view__get_width view_width
    local view_right=$(( $SHAPE_COL + $view_width ))

    [ $view_right -ge $RIGHT ]
}

get_shape_most_right_col() {
    local result="${1:?}"

    local view_width; shape_view__get_width view_width

    eval "$result=\$((\$RIGHT - \$view_width))"
}

get_shape_most_bottom_row() {
    local result="${1:?}"

    local view_height; shape_view__get_height view_height

    eval "$result=\$((\$BOTTOM - \$view_height))"
}

render_stage() {
    local line;
    printf -v line "$WALL%$WIDTH_INNER.${WIDTH_INNER}s$WALL" " "

    canvas__new stage_canvas
    canvas__set_foreground stage_canvas $WHITE
    canvas__cursor_at stage_canvas $ROW $COL
    for (( i = 0; i<$HEIGHT - 1; i++ )); do
        canvas__add_format_line stage_canvas "$line"
    done

    local bottom_line;
    printf -v bottom_line "$WALL%$WIDTH_INNER.${WIDTH_INNER}s$WALL" " "
    bottom_line="${bottom_line// /$FLOOR}"
    canvas__add_format_line stage_canvas "$bottom_line"

    canvas__render stage_canvas
}
