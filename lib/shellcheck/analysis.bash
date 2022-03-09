# Call out to shellcheck for common mistakes and advice

shellcheck::analyze() {
    local in_dir=$1 out_dir=$2 snake_slug=$3
    local opts=(
        "--shell=bash"  
        "--external-sources"
        "--check-sourced"
        "--norc"
        "--format=json1"
    )
    (
        cd "$in_dir" >/dev/null || exit 1
        shellcheck "${opts[@]}" "${snake_slug}.sh"
    ) \
    | tee "$out_dir/shellcheck_analysis.out" \
    | ruby bin/process-shellcheck-output.rb \
    | tee "$out_dir/shellcheck_analysis.json"
}
