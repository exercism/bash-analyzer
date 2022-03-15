#!/usr/bin/env bash

shopt -s extglob

usage() {
    printf '%s\n' "$*"
    printf '%s\n' "Usage: ${0##*/} slug input_dir output_dir"
    exit 1
}

die() {
    echo "$*" >&2
    exit 1
}

validate_input() {
    if ! [[ -d "$in_dir" && -r "$in_dir" ]]; then
        usage "Error: not a dir or not readable: ${in_dir@Q}"
    fi
    if ! [[ -d "$out_dir" && -w "$out_dir" ]]; then
        usage "Error: not a dir or not writable: ${out_dir@Q}"
    fi
    local source="$in_dir/${snake_slug}.sh"
    if ! [[ -f $source && -r $source ]]; then
        usage "Error: not a file or not readable: ${source@Q}"
    fi
}

invoke_analysis() {
    local module=$1
    if [[ -f "lib/$module/analysis.bash" ]]; then
        bash "lib/$module/analysis.bash" "$in_dir" "$out_dir" "$snake_slug" \
        || die "$module analysis exits non-zero."
    fi
}

main() {
    local slug=$1
    local in_dir=${2:-.}
    local out_dir=${3:-.}
    local snake_slug=${slug//-/_}

    validate_input

    # now run the checks. There will be (up to) 3 scripts executed:
    #
    # 1. shellcheck -- run this first, to seed the analysis.json file
    # 2. general, including checking for boiler-plate comments
    # 3. exercise-specific
    #
    # Each script will merge its results into the "analysis.json" output file.

    invoke_analysis shellcheck \
    && invoke_analysis general \
    && invoke_analysis "$slug"
}

main "$@"
