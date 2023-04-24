FROM ubuntu:22.04

# Ubuntu 22.04 ships with:
# - bash version "5.1.16(1)-release"
# APT installs:
# - bats v1.2.1
# - ruby v3.0.2p107
# - jq v"jq-1.6"
# Install latest shellcheck from its github releases
# - as of 2023-04-25, that is v0.9.0

RUN apt-get update && \
    apt-get install -y bats ruby jq wget && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget -q https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz && \
    tar Jxf ./shellcheck-stable.linux.x86_64.tar.xz && \
    cp ./shellcheck-stable/shellcheck /usr/local/bin && \
    rm -r ./shellcheck-stable.linux.x86_64.tar.xz ./shellcheck-stable/ && \
    shellcheck --version

RUN mkdir /opt/analyzer
COPY . /opt/analyzer
WORKDIR /opt/analyzer
ENTRYPOINT ["/opt/analyzer/bin/run.sh"]
