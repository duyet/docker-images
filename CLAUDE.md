# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of custom Docker images published to GitHub Container Registry (ghcr.io/duyet/docker-images). The repository follows a structured pattern where each image category has its own directory, and each specific image variant lives in a subdirectory with its own Dockerfile.

## Repository Structure

The repository is organized as follows:
- `<image_name>/<image_tag>/Dockerfile` - Each image variant has its own Dockerfile
- `gen.py` - Python script that generates GitHub Actions workflows and README documentation
- `.github/workflows/ci.yaml` - Auto-generated CI/CD pipeline for building and publishing images

### Image Categories
- `clickhouse-server/` - ClickHouse server variants (versions 24.x - 25.x)
- `debezium/` - Debezium CDC connector images
- `gcloud/` - Google Cloud SDK images with different Python versions
- `node/` - Node.js images (versions 22, 24)
- `rust/` - Rust-based tools (typos, sccache, cargo-audit, etc.)
- `kubeconform/` - Kubernetes manifest validation tool
- `upptime/` - Uptime monitoring service

## Development Workflow

### Adding New Images

1. Create directory structure: `<image_name>/<image_tag>/`
2. Add `Dockerfile` in the new directory
3. **REQUIRED**: Regenerate workflows and documentation:
   ```bash
   uv sync
   uv run python gen.py
   ```

   **⚠️ IMPORTANT**: You MUST run this command whenever you add or modify image directories. This regenerates the GitHub Actions workflow and updates the README with the new images. The CI/CD pipeline depends on the generated workflow file.

### Build System

The build system uses Python with Jinja2 templates to generate:
- `.github/workflows/ci.yaml` - GitHub Actions workflow
- `README.md` image documentation (between `<!-- BEGIN IMAGE LIST -->` and `<!-- END IMAGE LIST -->` markers)

#### Key Commands

```bash
# Install dependencies
uv sync

# Generate workflows and README
uv run python gen.py

# Preview changes (dry run)
uv run python gen.py --dry-run

# Get help
uv run python gen.py --help
```

### CI/CD Pipeline

GitHub Actions automatically:
- Builds images for modified directories only (using path filters)
- Supports multi-architecture builds (linux/amd64, linux/arm64)
- Tags images with:
  - The image tag name
  - Date-stamped version (`<tag>-YYYYMMDD`)
  - Git SHA
- Publishes to `ghcr.io/duyet/docker-images:<tag>`

### Image Naming Convention

Images are tagged using the pattern: `<image_name>_<version_or_variant>`

Examples:
- `clickhouse_25.6` (ClickHouse version 25.6)
- `node_24` (Node.js version 24)
- `gcloud_debian_python3` (GCloud with Debian and Python 3)

## Architecture Patterns

### Dockerfile Patterns

1. **Simple tool installation** (rust/typos):
   ```dockerfile
   FROM rust:1
   RUN cargo install typos-cli
   ```

2. **Base image extension** (clickhouse-server):
   ```dockerfile
   FROM clickhouse/clickhouse-server:25.6
   COPY --chmod=755 clickhouse-server/clickhouse_25.6/config.d/ /etc/clickhouse-server/config.d/
   ```

### Template System

The `gen.py` script uses Jinja2 templates to:
- Scan directories for Dockerfile patterns
- Generate matrix build strategies for GitHub Actions
- Maintain synchronized README documentation
- Handle workflow generation for multiple image families

### Path-based Builds

CI only builds images when their specific directories change, using GitHub Actions `dorny/paths-filter` to:
- Monitor `<image_name>/<image_tag>/**` paths
- Trigger builds only for modified images
- Include workflow file changes as build triggers

## Development Dependencies

- Python 3.9+ (managed via pyproject.toml)
- Jinja2 for template rendering
- uv for Python dependency management