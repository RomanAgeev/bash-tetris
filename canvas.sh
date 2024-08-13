#!/bin/bash

source ./utils/_main.sh

init_canvas() {
    CANVAS=
}

set_canvas_foreground() {
    local color="${1:?}"

    local suffix
    printf -v suffix "$SET_FG" "$color"

    _append_canvas_suffix "$suffix"
}

set_canvas_cursor_at() {
    local row="${1:?}"
    local col="${2:?}"

    _append_canvas_suffix "$CUR_ROW_COL" "$row" "$col"
}

add_canvas_format() {
    local format="${1:?}"

    shift 1

    _append_canvas_suffix "$format" "$@"
}

add_canvas_format_line() {
    local format="${1:?}"

    shift 1

    _append_canvas_suffix "$CUR_SAVE$format$CUR_RESTORE$CUR_DOWN" "$@"
}

add_canvas_string_line() {
    local string="${1:?}"

    add_canvas_format_line "%s" "$string"
}

render_canvas() {
    printf "$CANVAS\n" "$@"

    # set_foreground "$NEUTRAL"
    # set_background "$NEUTRAL"
}

_append_canvas_suffix() {
    local format="${1:?}"

    shift 1

    local suffix
    [ $# -gt 0 ] \
        && printf -v suffix "$format" "$@" \
        || suffix="$format"

    CANVAS="$CANVAS$suffix"
}
