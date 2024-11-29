FROM clickhouse/clickhouse-server:head

COPY --chmod=755 clickhouse-server/clickhouse_24.10/config.d/ /etc/clickhouse-server/config.d/
COPY --chmod=755 clickhouse-server/clickhouse_24.10/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY --chmod=755 clickhouse-server/clickhouse_24.10/keeper/ /keeper/
