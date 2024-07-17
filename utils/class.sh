#!/bin/bash

_field_name() {
    printf -v __FIELD_NAME "%s__%s" "${1:?}" "${2:?}"
}

set_field() {
    local this="${1:?}"
    local field="${2:?}"
    local value="${3:-}"

    _field_name "$this" "$field"

    eval "$__FIELD_NAME=\$value"
}

get_field() {
    local this="${1:?}"
    local field="${2:?}"

    _field_name "$this" "$field"

    eval "$field=\$$__FIELD_NAME"
}

set_array_field() {
    local this="${1:?}"
    local field="${2:?}"

    shift 2

    _field_name "$this" "$field"

    eval "$__FIELD_NAME=( \"\$@\" )"
}

get_array_field() {
    local this="${1:?}"
    local field="${2:?}"

    _field_name "$this" "$field"

    eval "$field=( \"\${$__FIELD_NAME[@]+\"\${$__FIELD_NAME[@]}\"}\" )"
}