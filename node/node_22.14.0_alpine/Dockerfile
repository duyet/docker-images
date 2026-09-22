# Pinned to a specific patch release + alpine variant (unlike the floating node_22 tag).
FROM node:22.14.0-alpine

# Standalone uv binary. Same file runs on Alpine.
COPY --from=ghcr.io/astral-sh/uv:0.6.10 /uv /uvx /usr/local/bin/

# python3 and zstd for child CI jobs. One apk layer, no compiler toolchain.
RUN apk add --no-cache python3 zstd
