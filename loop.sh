#!/bin/bash

source ./utils/_main.sh

loop() {
    local on_action="${1:?}"
    local on_timeout="${2:?}"
    local initial_timeout_ms="${3:-1000}"

    local timeout_ms="$initial_timeout_ms"

    while :; do
        local before_ms; get_timestamp_ms before_ms
        local _timeout; to_seconds "$timeout_ms" _timeout

        while :; do
            read -sn 1 -t "$_timeout" key || {
                "$on_timeout"
                timeout_ms="$initial_timeout_ms"
                get_timestamp_ms before_ms
                to_seconds "$timeout_ms" _timeout
                continue
            }

            "$on_action" "$key" && break
        done

        local after_ms; get_timestamp_ms after_ms
        timeout_ms=$(( $timeout_ms - $after_ms + $before_ms ))
    done
}