FROM docker:27-cli

# python3 and zstd for child CI jobs. One apk layer, no upgrade, no compiler.
RUN apk add --no-cache python3 zstd
