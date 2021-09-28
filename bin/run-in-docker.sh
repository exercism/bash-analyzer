#!/usr/bin/env bash
set -e

# Synopsis:
# Analysis runner for run.sh in a docker container
# Takes the same arguments as run.sh (EXCEPT THAT SOLUTION AND OUTPUT PATH ARE RELATIVE)
# Builds the Dockerfile
# Runs the docker image passing along the initial arguments

# Arguments:
# $1: exercise slug
# $2: **RELATIVE** path to solution folder (with trailing slash)
# $3: **RELATIVE** path to output directory (with trailing slash)

# Output:
# Writes the analyasis results to a analyasis.json file in the passed-in output directory.
# The results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/analyzers/interface.md

# Example:
# ./run-in-docker.sh two-fer ./relative/path/to/two-fer/solution/folder/ ./relative/path/to/output/directory/

# If arguments not provided, print usage and exit
if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    echo "usage: run-in-docker.sh exercise-slug ./relative/path/to/solution/folder/ ./relative/path/to/output/directory/"
    exit 1
fi

slug="$1"
input_dir="${2%/}"
output_dir="${3%/}"

# Create output directory if it doesn't exist
mkdir -p "${output_dir}"

# build docker image
docker build --rm --no-cache -t bash-analyzer .

# run image passing the arguments
docker run \
    --network none \
    --read-only \
    --mount type=bind,src="${PWD}/${input_dir}",dst=/solution \
    --mount type=bind,src="${PWD}/${output_dir}",dst=/output \
    --mount type=tmpfs,dst=/tmp \
    exercism/bash-analyzer "${slug}" /solution/ /output/
