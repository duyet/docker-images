FROM rust:1

ENV SCCACHE_LOG=trace
ENV PUBLIC_ADDR="0.0.0.0:10501"
ENV SCHEDULER_URL="http://127.0.0.1:10600"
ENV SCHEDULER_AUTH_TOKEN="duet"

RUN apt update && apt install -y bubblewrap && \
  cargo install sccache --features="dist-client,dist-server,s3,redis" && \
  which sccache && which sccache-dist && sccache --version

# Due to bubblewrap requirements currently the build server must be run as root.
USER root
COPY rust/sccache-server/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
