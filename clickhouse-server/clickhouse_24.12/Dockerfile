FROM clickhouse/clickhouse-server:24.12

COPY --chmod=755 clickhouse-server/clickhouse_24.12/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_24.12/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_24.12/keeper/ /keeper/
