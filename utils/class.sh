#!/bin/bash

set_field() {
    local this="${1:?}"
    local field="${2:?}"

    shift 2 

    if [ $# -gt 1 ]; then
        eval "${this}__$field=( \"\$@\" )"
    elif [ $# -eq 1 ]; then
        eval "${this}__$field=\$1"
    else
        printf "Value for the field \"%s__%s\" is not provided" "$this" "$field" >&2
        return 1
    fi
}

get_scalar_field() {
    local this="${1:?}"
    local field="${2:?}"

    eval "$field=\$${this}__$field"
}

get_array_field() {
    local this="${1:?}"
    local field="${2:?}"

    eval "$field=( \"\${${this}__$field[@]}\" )"
}