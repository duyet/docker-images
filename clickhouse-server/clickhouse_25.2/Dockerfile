FROM clickhouse/clickhouse-server:25.2
# The base image adds the rolling ClickHouse apt repo, so apt-get upgrade would
# replace the pinned server. Hold those packages; OS packages still upgrade.
RUN apt-mark hold clickhouse-server clickhouse-client clickhouse-common-static \
    && apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 clickhouse-server/clickhouse_25.2/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.2/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.2/keeper/ /keeper/
