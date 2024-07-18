#!/bin/bash

source ./utils/_main.sh

shape_classname=canvas

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

new_canvas() {
    local this="${1:?}"

    set_field "$this" body
}

_append_suffix() {
    local this="${1:?}"
    local format="${2:?}"

    shift 2

    local suffix
    [ $# -gt 0 ] \
        && printf -v suffix "$format" "$@" \
        || suffix="$format"

    local body; get_field "$this" body
    set_field "$this" body "$body$suffix"
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

    local body; get_field "$this" body

    printf "$body\n" "$@"
}
