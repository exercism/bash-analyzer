# check for boilerplate comments
general::boilerplate() {
    local comment='# *** PLEASE REMOVE THESE COMMENTS BEFORE SUBMITTING YOUR SOLUTION ***'
    grep -Fxq "$comment" "$filename" \
    && echo '{"comment": "bash.general.boilerplate_comment", "type": "actionable"}'
}

general::analyze() {
    local in_dir=$1 out_dir=$2 snake_slug=$3
    local filename="$in_dir/${snake_slug}.sh"
    local comments=()
    local IFS=,

    json=$(general::boilerplate)
    [[ -n $json ]] && comments+=("$json")

    # other checks can go here to add to the "comments" array

    if (( ${#comments[@]} > 0 )); then
        printf '{"comments": [%s]}\n' "${comments[*]}" \
        | tee "$out_dir/general_analysis.json"
    fi
}
