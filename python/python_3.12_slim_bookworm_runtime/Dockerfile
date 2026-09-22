FROM python:3.12-slim-bookworm

# curl plus the C++ runtime libs child images install again.
# One apt layer, lists removed, no compiler toolchain.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        libgcc-s1 \
        libstdc++6 \
    && rm -rf /var/lib/apt/lists/*
