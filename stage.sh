#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh

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
    SHAPE_ROW=$ROW
    SHAPE_COL=$(( $COL + $WIDTH / 2 - 1 ))
    render_shape
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

    init_canvas
    set_canvas_foreground $WHITE
    set_canvas_cursor_at $ROW $COL
    for (( i = 0; i<$HEIGHT - 1; i++ )); do
        add_canvas_format_line "$line"
    done

    local bottom_line;
    printf -v bottom_line "$WALL%$WIDTH_INNER.${WIDTH_INNER}s$WALL" " "
    bottom_line="${bottom_line// /$FLOOR}"
    add_canvas_format_line "$bottom_line"

    render_canvas
}
