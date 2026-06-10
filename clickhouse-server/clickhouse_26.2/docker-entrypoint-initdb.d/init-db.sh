#!/bin/bash
set -e

clickhouse client -n <<-EOSQL
    CREATE DATABASE data_lake;

    CREATE TABLE data_lake.events (
      event_name LowCardinality(String),
      event_value String,
      event_time DateTime DEFAULT now()
    ) ENGINE = MergeTree
    ORDER BY event_time;

    INSERT INTO data_lake.events (event_name, event_value)
    SELECT * FROM generateRandom('event_name LowCardinality(String), event_value String') LIMIT 100;

    INSERT INTO data_lake.events (event_name, event_value)
    SELECT * FROM generateRandom('event_name LowCardinality(String), event_value String') LIMIT 100;

    BACKUP TABLE data_lake.events TO Disk('backups', 'init_backup.zip');
EOSQL
