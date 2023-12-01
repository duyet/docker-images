#!/bin/bash
set -e

clickhouse client -n <<-EOSQL
    CREATE DATABASE data_lake;

    CREATE TABLE data_lake.events (
      event_name LowCardinality(String),
      event_value String
    ) ENGINE = Log;

    INSERT INTO data_lake.events
    SELECT * FROM generateRandom('event_name LowCardinality(String), event_value String') LIMIT 30;
EOSQL
