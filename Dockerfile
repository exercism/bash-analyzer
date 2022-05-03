FROM ubuntu:22.04

# Ubuntu 22.04 ships with:
# - bash version "5.1.16(1)-release"
# APT installs:
# - bats v1.2.1
# - ruby v3.0.2p107
# - shellcheck v0.8.0
# - jq v"jq-1.6"

RUN apt-get update && \
    apt-get install -y bats ruby shellcheck jq && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/analyzer
COPY . /opt/analyzer
WORKDIR /opt/analyzer
ENTRYPOINT ["/opt/analyzer/bin/run.sh"]
