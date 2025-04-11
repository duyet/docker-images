FROM clickhouse/clickhouse-server:25.02

COPY --chmod=755 clickhouse-server/clickhouse_25.02/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.02/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.02/keeper/ /keeper/
