#!/bin/bash

init_heap() {
    for (( i=0; i<$STAGE_INNER; i++ )); do
        eval "HEAP_$i=()"
    done
}

set_heap() {
    eval "HEAP_${1:?}[${2:?}]=\"\${3:?}\""
}

render_heap() {
    init_canvas
    for (( i=0; i<$STAGE_INNER; i++ )); do
        eval "local height=\${#HEAP_$i[@]}"
        for (( j=0; j<$height; j++ )); do
            eval "local color=\${HEAP_$i[$j]}"
            [ $color -ne $TRANSPARENT ] && {
                set_canvas_cursor_at $(( $STAGE_BOTTOM - $j - 1 )) $(( $STAGE_COL + $i + 1 ))
                set_canvas_foreground $color
                add_canvas_string $PLACEHOLDER
            }
        done
    done
    render_canvas
}

is_heap_hit() {
    local shift_down=${1:-1}
    local shift_left=${2:-0}
    local shift_right=${3:-0}

    local left=$(( $SHAPE_COL - $shift_left + $shift_right ))
    local top=$(( $SHAPE_ROW + $shift_down ))
    local right=$(( $left + $SHAPE_ACTUAL_WIDTH - 1 ))
    local bottom=$(( $top + $SHAPE_ACTUAL_HEIGHT - 1 ))

    eval "local shape_lines=( \"\${SHAPE_LINES_$SHAPE_ROTATION[@]}\" )"

    for (( i=0; i<$SHAPE_ACTUAL_WIDTH; i++ )); do
        local heap_i=$(( $left - $STAGE_COL + $i - 1 ))
        eval "local heap=( \"\${HEAP_$heap_i[@]}\" )"
        local heap_height=${#heap[@]}
        local heap_top=$(( $STAGE_BOTTOM - $heap_height ))
        [ $heap_top -lt $top ] && heap_top=$top
        for (( j=$heap_top; j<=$bottom; j++ )); do
            local line_j=$(( $j - $top ))
            local shape_line="${shape_lines[$line_j]}"
            [ "${shape_line:$i:1}" != "." ] && {
                return 0
            }
        done
    done
    return 1
}

update_heap() {
    eval "local shape_lines=( \"\${SHAPE_LINES_$SHAPE_ROTATION[@]}\" )"
    for (( i=0; i<$SHAPE_ACTUAL_WIDTH; i++ )); do
        local j
        for (( j=0; j<$SHAPE_ACTUAL_HEIGHT; j++ )); do
            local shape_line="${shape_lines[$j]}"
            [ "${shape_line:$i:1}" != "." ] && break
        done
        for (( ; j<$SHAPE_ACTUAL_HEIGHT; j++ )); do
            local shape_line="${shape_lines[$j]}"
            local color; [ "${shape_line:$i:1}" != "." ] && color="$SHAPE_COLOR" || color="$TRANSPARENT"
            local heap_i=$(( $SHAPE_COL - $STAGE_COL + $i - 1 ))
            local heap_j=$(( $STAGE_BOTTOM - $SHAPE_ROW - $j - 1 ))
            eval "local heap_height=\${#HEAP_$heap_i[@]}"
            for (( k=$heap_j-1; k>=$heap_height; k-- )); do
                set_heap $heap_i $k $TRANSPARENT
            done
            set_heap $heap_i $heap_j $color
        done
    done
}