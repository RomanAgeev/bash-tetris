#!/bin/bash

_installed() {
    local command="${1:?}"

    type "${command}" >/dev/null 2>&1
}

require() {
    local command="${1:?}"

    if ! _installed $command; then
        echo "'${command}' is not installed, exiting..." >&2
        exit 1
    fi
}
