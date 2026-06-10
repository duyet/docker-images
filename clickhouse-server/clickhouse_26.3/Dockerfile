FROM clickhouse/clickhouse-server:26.3
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 clickhouse-server/clickhouse_26.3/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_26.3/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_26.3/keeper/ /keeper/
