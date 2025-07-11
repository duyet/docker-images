FROM clickhouse/clickhouse-server:25.5

COPY --chmod=755 clickhouse-server/clickhouse_25.5/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.5/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.5/keeper/ /keeper/
