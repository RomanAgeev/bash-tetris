#!/bin/bash

fill_array() {
    local result="${1:?}"

    local length="${2:?}"
    if ! valid_int "$length"; then
        printf "Array length \"%s\" is not a number\n" "$length" >&2
        return 1
    fi

    if [ $length -le 0 ]; then
        printf "Array length %d cannot be negative" "$length" >&2
        return 1
    fi

    local string="${3:- }"

    local _array=()
    while [ ${#_array[@]} -lt $length ]; do
        _array+=( "$string" )
    done

    eval "$result=( \"\${_array[@]}\" )"
}
