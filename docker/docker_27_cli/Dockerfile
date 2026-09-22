FROM docker:27-cli

# python3 and zstd for child CI jobs. One apk layer, no compiler toolchain.
RUN apk --no-cache upgrade \
    && apk --no-cache add python3 zstd
