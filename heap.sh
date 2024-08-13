#!/bin/bash

init_heap() {
    HEAP_WIDTH=()
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
    local row=${1:-0}
    local placeholder="${2:- }"

    init_canvas
    for (( i=0; i<$STAGE_INNER; i++ )); do
        local heap_height; get_heap_height $i
        for (( j=$row; j<$heap_height; j++ )); do
            local heap_item; get_heap_item $i $j
            [ $heap_item -ne $TRANSPARENT ] && {
                set_canvas_cursor_at $(( $STAGE_BOTTOM - $j - 1 )) $(( $STAGE_COL + $i + 1 ))
                set_canvas_foreground $heap_item
                add_canvas_format "%s" "$placeholder"
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
        local heap_i=$(( $SHAPE_COL - $STAGE_COL + $i - 1 ))
        local heap_height; get_heap_height $heap_i

        local j=0
        for (( ; j<$SHAPE_ACTUAL_HEIGHT; j++ )); do
            local shape_line="${shape_lines[$j]}"
            [ "${shape_line:$i:1}" != "." ] && break
        done

        local heap_j
        for (( ; j<$SHAPE_ACTUAL_HEIGHT; j++ )); do
            heap_j=$(( $STAGE_BOTTOM - $SHAPE_ROW - $j - 1 ))
            local shape_line="${shape_lines[$j]}"
            [ "${shape_line:$i:1}" != "." ] && {
                set_heap_item $heap_i $heap_j $SHAPE_COLOR
                local heap_width=${HEAP_WIDTH[$heap_j]-0}
                heap_width=$(( $heap_width + 1 ))
                HEAP_WIDTH[$heap_j]=$heap_width
            } || {
                set_heap_item $heap_i $heap_j $TRANSPARENT
            }
        done

        for (( k=$heap_j-1; k>=$heap_height; k-- )); do
            set_heap_item $heap_i $k $TRANSPARENT
        done
    done
}

adjust_heap() {
    for (( i=0; i<$STAGE_INNER; i++ )); do
        eval "echo \"HEAP_${i}=( \"\${HEAP_$i[*]}\" )\""
    done

    return 0

    local row=
    for (( j=0; j<${#HEAP_WIDTH[@]}; j++ )); do
        [ ${HEAP_WIDTH[$j]} -eq $STAGE_INNER ] && {
            row=$j
            break
        }
    done

    [ -z "$row" ] && {
        render_heap 0 $PLACEHOLDER
        return 0
    }

    render_heap $row

    for (( j=$(( ${#HEAP_WIDTH[@]} - 1)); j>=$row; j-- )); do
        [ ${HEAP_WIDTH[$j]} -eq $STAGE_INNER ] && {
            unset HEAP_WIDTH[$j]
            for (( i=0; i<$STAGE_INNER; i++ )); do
                eval "unset HEAP_$i[$j]"
            done
        }
    done

    for (( i=0; i<$STAGE_INNER; i++ )); do
        eval "HEAP_$i=( \"\${HEAP_$i[@]}\" )"
    done
    HEAP_WIDTH=( "${HEAP_WIDTH[@]}" )

    render_heap $row $PLACEHOLDER
}
