#!/bin/bash

source ./utils/_main.sh

new_class canvas

canvas__new() {
    local this="${1:?}"

    __init_canvas "$this"

    __set_canvas_field "$this" body
}

canvas__free() {
    local this="${1:?}"

    __exist_canvas "$this" && __free_canvas "$this"
}

canvas__set_foreground() {
    local this="${1:?}"
    local color="${2:?}"

    local suffix
    printf -v suffix "$SET_FG" "$color"

    _canvas__append_suffix "$this" "$suffix"
}

canvas__cursor_at() {
    local this="${1:?}"
    local row="${2:?}"
    local col="${3:?}"

    _canvas__append_suffix "$this" "$CUR_ROW_COL" "$row" "$col"
}

canvas__add_format() {
    local this="${1:?}"
    local format="${2:?}"

    shift 2

    _canvas__append_suffix "$this" "$format" "$@"
}

canvas__add_string() {
    local this="${1:?}"
    local string="${2:?}"

    canvas__add_format "$this" "%s" "$string"
}

canvas__add_format_line() {
    local this="${1:?}"
    local format="${2:?}"

    shift 2

    _canvas__append_suffix "$this" "$CUR_SAVE$format$CUR_RESTORE$CUR_DOWN" "$@"
}

canvas__add_string_line() {
    local this="${1:?}"
    local string="${2:?}"

    canvas__add_format_line "$this" "%s" "$string"
}

canvas__render() {
    local this="${1:?}"

    shift 1

    local body; __get_canvas_field "$this" body 
    printf "$body\n" "$@"

    set_foreground "$NEUTRAL"
    set_background "$NEUTRAL"
}

_canvas__append_suffix() {
    local this="${1:?}"
    local format="${2:?}"

    shift 2

    local suffix
    [ $# -gt 0 ] \
        && printf -v suffix "$format" "$@" \
        || suffix="$format"

    local body; __get_canvas_field "$this" body
    __set_canvas_field "$this" body "$body$suffix"
}
