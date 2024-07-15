#/bin/bash

valid_int()
    case ${1#-} in
        *[!0-9]*) false ;;
        *) true ;;
    esac