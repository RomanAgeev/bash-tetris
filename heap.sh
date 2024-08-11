#!/bin/bash

init_heap() {
    for (( i=0; i<$STAGE_INNER; i++ )); do
        eval "HEAP_$i=()"
    done
}

set_heap_item() {
    eval "HEAP_${1:?}[${2:?}]=\"\${3:?}\""
}

get_heap_item() {
    eval "heap_item=\${HEAP_${1:?}[${2:?}]}"
}

get_heap_height() {
    eval "heap_height=\${#HEAP_${1:?}[@]}"
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
    local left=$SHAPE_COL
    local top=$SHAPE_ROW
    local right=$(( $left + $SHAPE_ACTUAL_WIDTH - 1 ))
    local bottom=$(( $top + $SHAPE_ACTUAL_HEIGHT - 1 ))

    eval "local shape_lines=( \"\${SHAPE_LINES_$SHAPE_ROTATION[@]}\" )"

    for (( i=0; i<$SHAPE_ACTUAL_WIDTH; i++ )); do
        local heap_i=$(( $left - $STAGE_COL + $i - 1 ))
        local heap_height; get_heap_height $heap_i
        local heap_top=$(( $STAGE_BOTTOM - $heap_height ))
        [ $heap_top -lt $top ] && heap_top=$top
        for (( j=$heap_top; j<=$bottom; j++ )); do
            local line_j=$(( $j - $top ))
            local heap_j=$(( $STAGE_BOTTOM - $j - 1 ))
            local shape_line="${shape_lines[$line_j]}"
            local heap_item; get_heap_item $heap_i $heap_j
            ([ "${shape_line:$i:1}" != "." ] && [ $heap_item -ne $TRANSPARENT ]) && return 0
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
            local heap_height; get_heap_height $heap_i
            for (( k=$heap_j-1; k>=$heap_height; k-- )); do
                set_heap_item $heap_i $k $TRANSPARENT
            done
            set_heap_item $heap_i $heap_j $color
        done
    done
}