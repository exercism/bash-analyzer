#!/usr/bin/env bash

shopt -s extglob

usage() {
    printf '%s\n' "$*"
    printf '%s\n' "Usage: ${0##*/} slug input_dir output_dir"
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

array_includes() {
    local -n arr=$1
    local elem=$2
    local IFS=:
    [[ ":${arr[*]}:" == *":$elem:"* ]]
}

merge_json() {
    local files=("$out_dir"/!(expected)_analysis.json)
    local summary

    # use the shellcheck summary if it exists
    if array_includes files "$out_dir/shellcheck_analysis.json"; then
        summary=$(jq -r .summary "$out_dir/shellcheck_analysis.json")
    fi

    # otherwise, perhaps choose a different one
    if [[ -z $summary || $summary == *"No Shellcheck suggestions"* ]]; then
        if (( ${#files[@]} < 2 )); then
            summary="Congrats! No suggestions"
        else
            summary="Some comments"
        fi
    fi

    # and merge the json files into "analysis.json"
    # thanks to https://stackoverflow.com/a/36218044/7552
    jq --arg sum "$summary" --slurp '{
        summary: $sum,
        comments: (reduce .[] as $item ([]; . + $item.comments))
    }' "${files[@]}" > "$out_dir/analysis.json"
}

main() {
    local slug=$1
    local in_dir=${2:-.}
    local out_dir=${3:-.}
    local snake_slug=${slug//-/_}

    validate_input

    # the analysis.bash is expected to have a namespaced `analyze` function.
    # e.g.
    #   "lib/foo-bar/analysis.bash"
    # contains
    #   foo_bar::analyze() { ... }
    #
    # Each analyze function will emit a *_analysis.json file
    # containing that module's list of comments to show the student:
    #   {"comments": [...]}

    local namespace
    for module in general shellcheck "$slug"; do
        src_file="lib/$module/analysis.bash"
        if [[ -f $src_file ]]; then
            namespace=${module//-/_}

            source "$src_file" \
            && "${namespace}::analyze" "$in_dir" "$out_dir" "$snake_slug"
        fi
    done

    merge_json
}

main "$@"
