FROM debian:stable-slim

# curl, python3, and zstd for child CI jobs.
# No apt upgrade: that rewrites the whole OS layer and is slower to build.
# python3-minimal is enough to run scripts and is smaller than python3.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        python3-minimal \
        zstd \
    && rm -rf /var/lib/apt/lists/*
