#!/usr/bin/env bash

shopt -s extglob

usage() {
    printf '%s\n' "$*"
    printf '%s\n' "Usage: ${0##*/} slug input_dir output_dir"
    exit 1
}

validate() {
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

    if array_includes files "$out_dir/shellcheck_analysis.json"; then
        summary=$(jq -r .summary "$out_dir/shellcheck_analysis.json")
    fi

    case "$summary" in
        "" | *"No Shellcheck suggestions"* )
            if (( ${#files[@]} < 2 )); then
                summary="Congrats! No suggestions"
            else
                summary="Some comments"
            fi
            ;;
        *) : ;;
    esac

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

    validate

    # the analysis.bash is expected to have a namespaced
    # `analyze` function.
    # e.g.
    #   "lib/foo-bar/analysis.bash"
    # contains
    #   foo_bar::analyze() { ... }

    local namespace
    for module in general shellcheck "$slug"; do
        namespace=${module//-/_}
        if [[ -d "lib/$module" && -f "lib/$module/analysis.bash" ]]; then
            source "lib/$module/analysis.bash" \
            && "${namespace}::analyze" "$in_dir" "$out_dir" "$snake_slug"
        fi
    done

    merge_json
}

main "$@"
