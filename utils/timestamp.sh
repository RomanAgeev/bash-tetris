#!/bin/bash

get_timestamp_ms() {
    local result="${1:?}"

    eval "$result=\$( gdate +%s%3N )"
}

to_seconds() {
    local ms="${1:?}"
    local result="${2:?}"

    eval "$result=\$( bc <<< \"scale=3; $ms / 1000\" )"
}