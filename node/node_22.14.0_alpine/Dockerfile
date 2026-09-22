# Pinned to a specific patch release + alpine variant (unlike the floating node_22 tag).
FROM node:22.14.0-alpine

# python3 and zstd for child CI jobs. One apk layer, no compiler toolchain.
RUN apk add --no-cache python3 zstd
