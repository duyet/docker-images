# Build stage
FROM golang:1.24-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git make

# Set working directory
WORKDIR /go/src/github.com/minio/minio

# Clone MinIO repository
RUN git clone https://github.com/minio/minio.git . && \
    git checkout master

# Build MinIO
RUN make build

# Runtime stage
FROM alpine:latest

# Install ca-certificates for HTTPS
RUN apk add --no-cache ca-certificates

# Copy the binary from builder
COPY --from=builder /go/src/github.com/minio/minio/minio /usr/local/bin/minio

# Create minio user
RUN addgroup -g 1000 minio && \
    adduser -D -u 1000 -G minio minio

# Set up data directory
RUN mkdir -p /data && \
    chown -R minio:minio /data

# Expose MinIO ports
EXPOSE 9000 9001

# Set user
USER minio

# Set environment variables
ENV MINIO_ROOT_USER=minioadmin \
    MINIO_ROOT_PASSWORD=minioadmin

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["/usr/local/bin/minio", "healthcheck"]

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/minio"]

# Default command
CMD ["server", "/data", "--console-address", ":9001"]
