FROM clickhouse/clickhouse-server:24.9

COPY --chmod=755 clickhouse-server/clickhouse_24.9/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_24.9/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_24.9/keeper/ /keeper/