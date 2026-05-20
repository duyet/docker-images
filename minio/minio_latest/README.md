# MinIO - Built from Source

This image builds MinIO from source during image build.

## Usage

### Run with custom credentials

```bash
docker run -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=myadmin \
  -e MINIO_ROOT_PASSWORD=mysecretpassword \
  -v /path/to/data:/data \
  ghcr.io/duyet/docker-images:minio_latest
```

### Build from a pinned MinIO ref

```bash
docker build \
  --build-arg MINIO_REF=RELEASE.2025-10-15T17-29-55Z \
  -t ghcr.io/duyet/docker-images:minio_latest \
  -f minio/minio_latest/Dockerfile .
```

## Ports

- `9000`: MinIO S3 API
- `9001`: MinIO Console

## Required environment variables

- `MINIO_ROOT_USER`
- `MINIO_ROOT_PASSWORD`
