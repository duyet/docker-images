# MinIO - Built from Source

This image builds MinIO from the latest source code on the master branch.

## Usage

### Basic usage with default credentials

```bash
docker run -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  ghcr.io/duyet/docker-images:minio_latest
```

### Production usage with custom credentials

```bash
docker run -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=myadmin \
  -e MINIO_ROOT_PASSWORD=mysecretpassword \
  -v /path/to/data:/data \
  ghcr.io/duyet/docker-images:minio_latest
```

### Docker Compose

```yaml
version: '3.8'

services:
  minio:
    image: ghcr.io/duyet/docker-images:minio_latest
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: myadmin
      MINIO_ROOT_PASSWORD: mysecretpassword
    volumes:
      - minio_data:/data
    healthcheck:
      test: ["CMD", "/usr/local/bin/minio", "healthcheck"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 5s

volumes:
  minio_data:
```

## Ports

- **9000**: MinIO API (S3-compatible)
- **9001**: MinIO Console (Web UI)

## Environment Variables

- `MINIO_ROOT_USER`: Root username (required)
- `MINIO_ROOT_PASSWORD`: Root password (required, minimum 8 characters)

## Security Notes

⚠️ **Important**: Always set custom credentials via environment variables. Never use default credentials in production.

## Build Information

This image:
- Builds MinIO from the latest source code
- Uses multi-stage build for minimal image size
- Runs as non-root user (minio:minio)
- Includes health checks
- Supports both amd64 and arm64 architectures
