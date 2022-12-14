#!/bin/bash

#
# Build a json representing a directory structure from the given path.
#  
# Parameters:
# [path]: Path from which to build the json file. Default value is '.'.
#
# Author: Dalton Martins - daltonvlm (daltonvlm@gmail.com)
# Since: 2022-09-04
#

# TODO: handle file names with spaces

function help() {
    echo "Build a json representing a directory structure from the given path."
    echo ""
    echo "Usage: $prog [path]"
    echo "Or: '$prog -h' to print this help."
    echo ""
    echo "Path: Path from which to build the json file. Default value is '.'."
    exit $1
}

function internalError() {
    echo "[$1:$2] Internal error."
    exit 1
}

function buildJson() {
    test "$1" || >&2 internalError "$0" "$LINENO"

    local path="$1"
    local spaces="$2"
    local name=`basename "$path"`
    local size=`du -hs "$path" | tr [:blank:] '_' | cut -d_ -f1`
    local comma=
    local children=`ls "$path"`

    test -f "$path" && printf '%s{ "path": "%s", "name": "%s", "size": "%s" }'\
            "$spaces" "$path" "$name" "$size" && return

    printf '%s{\n' "$spaces"
    printf '%s  "path": "%s",\n' "$spaces" "$path"
    printf '%s  "name": "%s",\n' "$spaces" "$name"
    printf '%s  "size": "%s",\n' "$spaces" "$size"
    printf '%s  "children": [' "$spaces"

    test ! "$children" && printf ']\n%s}' "$spaces" && return
    echo

    for child in $children;
    do
        echo -en "$comma"
        buildJson "${path}/$child" "${spaces:-  }${spaces:-  }"
        comma=',\n'
    done

    test "$children" && printf '\n%s  ]\n%s}' "$spaces" "$spaces"
        
}

function main() {
    test ! "$path" && help 1
    test "$path" = -h && help
    test ! -e "$path" && >&2 printf "File '%s' not found.\n" "$path" && exit 1

    buildJson "$path"
    echo
} 


prog=`basename "$0"`
path=`echo "${1:-.}" | cut -d' ' -f1`
test "$path" = "/" || path=`echo ${path%/}`

main
