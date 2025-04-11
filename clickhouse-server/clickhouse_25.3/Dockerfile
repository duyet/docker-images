FROM clickhouse/clickhouse-server:25.3

COPY --chmod=755 clickhouse-server/clickhouse_25.3/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.3/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.3/keeper/ /keeper/
