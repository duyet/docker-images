FROM debian:stable-slim

# curl, python3, and zstd for child CI jobs. One apt layer, lists removed.
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        curl \
        python3 \
        zstd \
    && rm -rf /var/lib/apt/lists/*
