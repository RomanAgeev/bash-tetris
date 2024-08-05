#!/bin/bash

ESC=$'\e'
CSI=$ESC[

CUR_HIDE="${CSI}?25l"
CUR_SHOW="${CSI}?25h"

CUR_ROW_COL="${CSI}%d;%dH"
CUR_SAVE="${CSI}s"
CUR_RESTORE="${CSI}u"
CUR_UP_N="${CSI}%sA"
CUR_DOWN_N="${CSI}%sB"
CUR_RIGHT_N="${CSI}%sC"

printf -v CUR_UP "$CUR_UP_N" "1"
printf -v CUR_DOWN "$CUR_DOWN_N" "1"
printf -v CUR_RIGHT "$CUR_RIGHT_N" "1"

TRANSPARENT=-1
BLACK=0
RED=1
GREEN=2
YELLOW=3
BLUE=4
MAGENTA=5
CYAN=6
WHITE=7
NEUTRAL=$BLACK

FG=3
BG=4

SET_BG="${CSI}${BG}%dm"
SET_FG="${CSI}${FG}%dm"

hide_cursor() {
    printf "$CUR_HIDE"
}

show_cursor() {
    printf "$CUR_SHOW"
}

set_foreground() {
    local color="${1:?}"

    printf "$SET_FG" "$color"
}

set_background() {
    local color="${1:?}"

    printf "$SET_BG" "$color"
}

get_window_size() {
    local wresult=${1:?}
    local hresult=${2:?}

    shopt -s checkwinsize; (:); eval "$wresult=\$COLUMNS; $hresult=\$LINES"
}
