FROM clickhouse/clickhouse-server:25.4

COPY --chmod=755 clickhouse-server/clickhouse_25.4/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.4/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.4/keeper/ /keeper/
