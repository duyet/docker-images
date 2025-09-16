FROM debian:bookworm-slim

# Install dependencies and Google Cloud SDK
RUN apt-get update && apt-get install -y \
  git \
  build-essential \
  python3 \
  pipenv \
  python3-pip \
  jq \
  curl \
  gnupg \
  lsb-release \
  apt-transport-https \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg \
    && apt-get update && apt-get install -y google-cloud-cli \
    && rm -rf /var/lib/apt/lists/*

# Set up gcloud path
ENV PATH="/usr/bin:${PATH}"
