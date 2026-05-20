# Build stage
FROM golang:1.24-alpine AS builder

ARG MINIO_REF=master

# Build dependencies required by MinIO's Makefile.
RUN apk add --no-cache bash gcc git make musl-dev

WORKDIR /src
RUN git clone --depth 1 --branch "${MINIO_REF}" https://github.com/minio/minio.git .
RUN make build

# Runtime stage
FROM alpine:3.20

RUN apk add --no-cache ca-certificates
RUN addgroup -S minio && adduser -S -G minio minio
RUN mkdir -p /data && chown -R minio:minio /data

COPY --from=builder /src/minio /usr/local/bin/minio

USER minio:minio

EXPOSE 9000 9001

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --spider --quiet http://127.0.0.1:9000/minio/health/live || exit 1

ENTRYPOINT ["/usr/local/bin/minio"]
CMD ["server", "/data", "--console-address", ":9001"]
