#!/bin/bash

source ./utils/_main.sh

new_class canvas

new_canvas() {
    local this="${1:?}"
    local neutral_color="${2:-$BLACK}"

    set_canvas_field "$this" body
    set_canvas_field "$this" neutral_color "$neutral_color"
}

_append_canvas_suffix() {
    local this="${1:?}"
    local format="${2:?}"

    shift 2

    local suffix
    [ $# -gt 0 ] \
        && printf -v suffix "$format" "$@" \
        || suffix="$format"

    local body; get_canvas_field "$this" body
    set_canvas_field "$this" body "$body$suffix"
}

set_canvas_foreground() {
    local this="${1:?}"
    local color="${2:?}"

    local suffix
    printf -v suffix "$SET_FG" "$color"

    _append_canvas_suffix "$this" "$suffix"
}

set_canvas_background() {
    local this="${1:?}"
    local color="${2:?}"

    local suffix
    printf -v suffix "$SET_BG" "$color"

    _append_canvas_suffix "$this" "$suffix"
}

canvas_cursor_at() {
    local this="${1:?}"
    local row="${2:?}"
    local col="${3:?}"

    _append_canvas_suffix "$this" "$CUR_ROW_COL" "$row" "$col"
}

add_canvas_format() {
    local this="${1:?}"
    local format="${2:?}"

    shift 2

    _append_canvas_suffix "$this" "$format" "$@"
}

add_canvas_string() {
    local this="${1:?}"
    local string="${2:?}"

    add_canvas_format "$this" "%s" "$string"
}

add_canvas_format_line() {
    local this="${1:?}"
    local format="${2:?}"

    shift 2

    _append_canvas_suffix "$this" "$CUR_SAVE$format$CUR_RESTORE$CUR_DOWN" "$@"
}

add_canvas_string_line() {
    local this="${1:?}"
    local string="${2:?}"

    add_canvas_format_line "$this" "%s" "$string"
}

render_canvas() {
    local this="${1:?}"

    shift 1

    local body; get_canvas_field "$this" body 
    printf "$body\n" "$@"

    local neutral_color; get_canvas_field "$this" neutral_color
    set_foreground "$neutral_color"
    set_background "$neutral_color"
}
