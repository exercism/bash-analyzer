#!/usr/bin/env bash

die() { echo "$*" >&2; exit 1; }

usage() {
    local usage="Usage: ${0##*/} slug inputDir outputDir"
    (($#)) && printf -v usage '%s\n%s' "$*" "$usage"
    die "$usage"
}

analyze() {
    local opts=(
        "--shell=bash"  
        "--external-sources"
        "--check-sourced"
        "--norc"
        "--format=json1"
    )
    (
        cd "$inDir" >/dev/null
        shellcheck "${opts[@]}" "${filename}.sh"
    )
}

process() {
    # this reads stdin and emits to stdout
    ruby bin/process-shellcheck-output.rb
}

validate() {
    if ! [[ -d "$inDir" && -r "$inDir" ]]; then
        usage "Error: not a dir or not readable: '$inDir'"
    fi
    if ! [[ -d "$outDir" && -w "$outDir" ]]; then
        usage "Error: not a dir or not writable: '$outDir'"
    fi
    local source="$inDir/${filename}.sh"
    if ! [[ -f $source && -r $source ]]; then
        usage "Error: not a file or not readable: '$source'"
    fi
}

main() {
    local slug=$1
    local inDir=${2:-.}
    local outDir=${3:-.}
    local filename=${slug//-/_}

    validate

    analyze \
    | process \
    | tee "$outDir/analysis.json"
}

main "$@"
