#!/bin/bash

new_class() {
    class="${1:?}"
    static="${2:-__static}"

    template ./templates/class.shtmpl class="$class" static="$static"
}
