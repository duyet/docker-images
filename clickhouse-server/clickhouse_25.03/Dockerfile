FROM clickhouse/clickhouse-server:25.03

COPY --chmod=755 clickhouse-server/clickhouse_25.03/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.03/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_25.03/keeper/ /keeper/
