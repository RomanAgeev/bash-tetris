#!/bin/bash

source ./utils/_main.sh

new_class canvas

ESC=$'\e'
CSI=$ESC[

CUR_HIDE="${CSI}?25l"
CUR_SHOW="${CSI}?25h"

CUR_ROW_COL="${CSI}%d;%dH"
CUR_SAVE="${CSI}s"
CUR_RESTORE="${CSI}u"
CUR_UP_N="${CSI}%sA"
CUR_DOWN_N="${CSI}%sB"

printf -v CUR_UP "$CUR_UP_N" "1"
printf -v CUR_DOWN "$CUR_DOWN_N" "1"

BLACK=0
RED=1
GREEN=2
YELLOW=3
BLUE=4
MAGENTA=5
CYAN=6
WHITE=7

FG=3
BG=4

SET_BG="${CSI}${BG}%dm"
SET_FG="${CSI}${FG}%dm"

new_canvas() {
    local this="${1:?}"
    local neutral_color="${2:-$BLACK}"

    set_canvas_field "$this" body
    set_canvas_field "$this" neutral_color "$neutral_color"
}

_append_suffix() {
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

set_foreground() {
    local this="${1:?}"
    local color="${2:?}"

    local suffix
    printf -v suffix "$SET_FG" "$color"

    _append_suffix "$this" "$suffix"
}

set_background() {
    local this="${1:?}"
    local color="${2:?}"

    local suffix
    printf -v suffix "$SET_BG" "$color"

    _append_suffix "$this" "$suffix"
}

hide_cursor() {
    local this="${1:?}"

    _append_suffix "$this" "$CUR_HIDE"
}

show_cursor() {
    local this="${1:?}"

    _append_suffix "$this" "$CUR_SHOW"
}

cursor_at() {
    local this="${1:?}"
    local row="${2:?}"
    local col="${3:?}"

    _append_suffix "$this" "$CUR_ROW_COL" "$row" "$col"
}

add_format() {
    local this="${1:?}"
    local format="${2:?}"

    shift 2

    _append_suffix "$this" "$format" "$@"
}

add_string() {
    local this="${1:?}"
    local string="${2:?}"

    add_format "$this" "%s" "$string"
}

add_format_line() {
    local this="${1:?}"
    local format="${2:?}"

    shift 2

    _append_suffix "$this" "$CUR_SAVE$format$CUR_RESTORE$CUR_DOWN" "$@"
}

add_string_line() {
    local this="${1:?}"
    local string="${2:?}"

    add_format_line "$this" "%s" "$string"
}

render_canvas() {
    local this="${1:?}"

    shift 1

    local body; get_canvas_field "$this" body
    local neutral_color; get_canvas_field "$this" neutral_color
    printf -v neutral_foreground "$SET_FG" "$neutral_color"

    printf "$body$neutral_foreground\n" "$@"
}
