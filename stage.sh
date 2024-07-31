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
    local shape="${1:?}"
    local view="${2:?}"

    new_shape_view "$view" "$shape"

    local start_col=$(( $COL + $WIDTH / 2 - 1 ))

    move_shape_view_at "$view" "$ROW" "$start_col"
}

is_shape_down() {
    local view="${1:?}"

    local view_row; get_shape_view_row "$view" view_row
    local view_height; get_shape_view_height "$view" view_height
    local view_bottom=$(( $view_row + $view_height ))

    [ $view_bottom -ge $BOTTOM ]
}

is_shape_left() {
    local view="${1:?}"

    local view_col; get_shape_view_col "$view" view_col

    [ $view_col -le $(( $COL + 1 )) ]
}

is_shape_right() {
    local view="${1:?}"

    local view_col; get_shape_view_col "$view" view_col
    local view_width; get_shape_view_width "$view" view_width
    local view_right=$(( $view_col + $view_width ))

    [ $view_right -ge $RIGHT ]
}

get_shape_most_right_col() {
    local view="${1:?}"
    local result="${2:?}"

    local view_width; get_shape_view_width "$view" view_width

    eval "$result=\$((\$RIGHT - \$view_width))"
}

get_shape_most_bottom_row() {
    local view="${1:?}"
    local result="${2:?}"

    local view_height; get_shape_view_height "$view" view_height

    eval "$result=\$((\$BOTTOM - \$view_height))"
}

render_stage() {
    local line;
    printf -v line "$WALL%$WIDTH_INNER.${WIDTH_INNER}s$WALL" " "

    new_canvas stage_canvas
    set_canvas_foreground stage_canvas $WHITE
    canvas_cursor_at stage_canvas $ROW $COL
    for (( i = 0; i<$HEIGHT - 1; i++ )); do
        add_canvas_format_line stage_canvas "$line"
    done

    local bottom_line;
    printf -v bottom_line "$WALL%$WIDTH_INNER.${WIDTH_INNER}s$WALL" " "
    bottom_line="${bottom_line// /$FLOOR}"
    add_canvas_format_line stage_canvas "$bottom_line"

    render_canvas stage_canvas
}
