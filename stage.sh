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
    init_shape_view

    local start_col=$(( $COL + $WIDTH / 2 - 1 ))

    shape_view__move_at "$ROW" "$start_col"
}

is_shape_down() {
    [ $(( $SHAPE_ROW + $SHAPE_ACTUAL_HEIGHT )) -ge $BOTTOM ]
}

is_shape_left() {
    [ $SHAPE_COL -le $(( $COL + 1 )) ]
}

is_shape_right() {
    [ $(( $SHAPE_COL + $SHAPE_ACTUAL_WIDTH )) -ge $RIGHT ]
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
