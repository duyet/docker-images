FROM clickhouse/clickhouse-server:24.8

COPY clickhouse-server/clickhouse_24.8/config.d/ /etc/clickhouse-server/config.d/
COPY clickhouse-server/clickhouse_24.8/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY clickhouse-server/clickhouse_24.8/keeper/ /keeper/