FROM ubuntu:26.04@sha256:f3d28607ddd78734bb7f71f117f3c6706c666b8b76cbff7c9ff6e5718d46ff64

# Bats 1.13.0
# GNU bash, version 5.3.9(1)-release (x86_64-pc-linux-gnu)
# jq-1.8.1
# ruby 3.3.8 (2025-04-09 revision b200bad6cd) [x86_64-linux-gnu]
# ShellCheck version: 0.11.0

RUN apt-get update && \
    apt-get install --yes --no-install-recommends ca-certificates bats ruby jq wget xz-utils && \
    apt-get purge --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget -q https://github.com/koalaman/shellcheck/releases/download/v0.11.0/shellcheck-v0.11.0.linux.x86_64.tar.xz -O- \
    | tar -J --extract shellcheck-v0.11.0/shellcheck --to-stdout > /usr/local/bin/shellcheck && \
    chmod 755 /usr/local/bin/shellcheck

RUN mkdir /opt/analyzer
COPY . /opt/analyzer
WORKDIR /opt/analyzer
ENTRYPOINT ["/opt/analyzer/bin/run.sh"]
