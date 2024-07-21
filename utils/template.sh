#!/bin/bash

template() {
    src="${1:?}"

    shift 1

    script=$(cat "$src")

    for param; do
        local name="${param%=*}"
        local value="${param#*=}"
        script="${script//%%\{$name\}/$value}"
    done

    eval "$script"
}
