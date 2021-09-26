#!/usr/bin/env bash

usage() {
    printf '%s\n' "$*"
    printf '%s\n' "Usage: ${0##*/} slug inputDir outputDir"
    exit 1
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
        cd "$inDir" >/dev/null || exit 1
        shellcheck "${opts[@]}" "${filename}.sh"
    )
}

process() {
    # this reads stdin and emits to stdout
    ruby bin/process-shellcheck-output.rb
}

validate() {
    if ! [[ -d "$inDir" && -r "$inDir" ]]; then
        usage "Error: not a dir or not readable: ${inDir@Q}"
    fi
    if ! [[ -d "$outDir" && -w "$outDir" ]]; then
        usage "Error: not a dir or not writable: ${outDir@Q}"
    fi
    local source="$inDir/${filename}.sh"
    if ! [[ -f $source && -r $source ]]; then
        usage "Error: not a file or not readable: ${source@Q}"
    fi
}

main() {
    local slug=$1
    local inDir=${2:-.}
    local outDir=${3:-.}
    local filename=${slug//-/_}

    validate

    analyze \
    | tee "$outDir/analysis.out" \
    | process \
    | tee "$outDir/analysis.json"
}

main "$@"
