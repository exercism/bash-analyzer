#!/usr/bin/env sh

# Build the Docker image
docker build --rm -t exercism/bash-analyzer .

# Print tool versions inside Docker
docker run --rm -it --entrypoint /bin/bash exercism/bash-analyzer -c 'for i in bats bash jq ruby; do "$i" --version | head -n1; done; shellcheck --version | head -n2'
