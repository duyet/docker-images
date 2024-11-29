FROM clickhouse/clickhouse-server:head

COPY clickhouse-server/clickhouse_24.10/config.d/ /etc/clickhouse-server/config.d/
COPY clickhouse-server/clickhouse_24.10/docker-entrypoint-initdb.d/ /docker-entrypoint-initdb.d/
COPY clickhouse-server/clickhouse_24.10/keeper/ /keeper/
