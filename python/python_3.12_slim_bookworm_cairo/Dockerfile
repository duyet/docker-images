FROM ghcr.io/duyet/docker-images:python_3.12_slim_bookworm_runtime

# Pango, Cairo, and gdk-pixbuf for HTML or PDF rendering.
# One apt layer on top of the runtime image. No browser, no compiler.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libcairo2 \
        libgdk-pixbuf-2.0-0 \
        shared-mime-info \
    && rm -rf /var/lib/apt/lists/*
