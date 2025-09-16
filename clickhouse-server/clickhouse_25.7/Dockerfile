FROM clickhouse/clickhouse-server:25.7

COPY --chmod=755 clickhouse-server/clickhouse_25.7/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.7/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.7/keeper/ /keeper/