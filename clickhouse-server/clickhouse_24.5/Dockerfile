FROM clickhouse/clickhouse-server:24.5

COPY clickhouse-server/clickhouse_24.5/config.d/ /etc/clickhouse-server/config.d/
COPY clickhouse-server/clickhouse_24.5/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY clickhouse-server/clickhouse_24.5/keeper/ /keeper/