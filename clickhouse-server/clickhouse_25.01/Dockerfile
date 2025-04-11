FROM clickhouse/clickhouse-server:25.01

COPY --chmod=755 clickhouse-server/clickhouse_25.01/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.01/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.01/keeper/ /keeper/
