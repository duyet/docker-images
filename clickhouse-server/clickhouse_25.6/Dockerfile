FROM clickhouse/clickhouse-server:25.6

COPY --chmod=755 clickhouse-server/clickhouse_25.6/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.6/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.6/keeper/ /keeper/
