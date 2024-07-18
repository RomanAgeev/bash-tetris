#!/bin/bash

fill_array() {
    local length="${1:?}"
    if ! valid_int "$length"; then
        printf "Array length \"%s\" is not a number\n" "$length" >&2
        return 1
    fi

    if [ $length -le 0 ]; then
        printf "Array length %d cannot be negative" "$length" >&2
        return 1
    fi

    local string="${2:?}"

    __FILL_ARRAY=()
    while [ ${#__FILL_ARRAY[@]} -lt $length ]; do
        __FILL_ARRAY+=( $string )
    done
}
