FROM clickhouse/clickhouse-server:24.7

COPY --chmod=755 clickhouse-server/clickhouse_24.7/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_24.7/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_24.7/keeper/ /keeper/