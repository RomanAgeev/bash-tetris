#!/bin/bash

source ./utils/_main.sh
source ./canvas.sh
source ./shape_view.sh

new_class stage

set_stage_wall_pleceholder() {
    set_stage_static_field wall_placeholder "${1:?}"
}

get_stage_wall_pleceholder() {
    get_stage_static_field wall_placeholder
}

set_stage_floor_pleceholder() {
    set_stage_static_field floor_placeholder "${1:?}"
}

get_stage_floor_pleceholder() {
    get_stage_static_field floor_placeholder
}

new_stage() {
    local this="${1:?}"
    local row=${2:?}
    local col=${3:?}
    local width=${4:?}
    local height=${5:?}

    set_stage_field "$this" row "$row"
    set_stage_field "$this" col "$col"
    set_stage_field "$this" width "$width"
    set_stage_field "$this" height "$height"
}

start_stage_shape() {
    local this="${1:?}"
    local shape="${2:?}"
    local shape_view="${3:?}"

    new_shape_view "$shape_view" "$shape"

    local color_index=$(( $RANDOM % ${#colors[@]} ))
    set_shape_view_color "$shape_view" "${colors[$color_index]}"

    local row; get_stage_field "$this" row
    local col; get_stage_field "$this" col
    local width; get_stage_field "$this" width
    local start_col=$(( $col + $width / 2 - 1 ))

    enabled_shape_view_render "$shape_view"
    move_shape_view_at "$shape_view" $row $start_col
}

is_shape_parked_in_stage() {
    local this="${1:?}"
    local shape_view="${2:?}"
    local result="${3:?}"

    local view_row; get_shape_view_row "$shape_view" view_row
    local view_height; get_shape_view_height "$shape_view" view_height
    local view_bottom=$(( $view_row + $view_height ))

    local row; get_stage_field "$this" row
    local height; get_stage_field "$this" height
    local bottom=$(( $row + $height ))

    [ $view_bottom -lt $bottom ] && eval "$result=$NO" || eval "$result=$YES"
}

get_shape_park_row_in_stage() {
    local this="${1:?}"
    local shape_view="${2:?}"
    local result="${3:?}"

    local view_height; get_shape_view_height "$shape_view" view_height

    local row; get_stage_field "$this" row
    local height; get_stage_field "$this" height
    local bottom=$(( $row + $height ))

    eval "$result=\$((\$bottom - \$view_height))"
}

render_stage() {
    local this="${1:?}"

    local row; get_stage_field "$this" row
    local col; get_stage_field "$this" col
    local width; get_stage_field "$this" width
    local height; get_stage_field "$this" height

    local wall_placeholder; get_stage_wall_pleceholder
    local floor_placeholder; get_stage_floor_pleceholder

    local canvas; _stage_field_name "$this" canvas

    local inner_width=$(( $width - 1 ))

    local line;
    printf -v line "$wall_placeholder%$inner_width.${inner_width}s$wall_placeholder" " "

    new_canvas "$canvas"
    set_canvas_foreground "$canvas" "$WHITE"
    canvas_cursor_at "$canvas" "$row" "$col"
    for (( i=0; i<$height-1; i++ )); do
        add_canvas_format_line "$canvas" "$line"
    done

    local bottom_line;
    printf -v bottom_line "$wall_placeholder%$inner_width.${inner_width}s$wall_placeholder" " "
    bottom_line="${bottom_line// /$floor_placeholder}"
    add_canvas_format_line "$canvas" "$bottom_line"

    render_canvas "$canvas"
}

set_stage_wall_pleceholder "|"
set_stage_floor_pleceholder "_"