FROM clickhouse/clickhouse-server:25.8

COPY --chmod=755 clickhouse-server/clickhouse_25.8/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.8/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.8/keeper/ /keeper/