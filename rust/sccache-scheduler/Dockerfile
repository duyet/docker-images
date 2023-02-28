FROM rust:1

ENV SCCACHE_LOG=trace
ENV PUBLIC_ADDR="0.0.0.0:10600"
ENV CLIENT_AUTH_TOKEN="duet"
ENV SERVER_AUTH_TOKEN="duet"

RUN cargo install sccache --features="dist-client,dist-server,s3,redis" && \
  which sccache && which sccache-dist && sccache --version
COPY rust/sccache-scheduler/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
