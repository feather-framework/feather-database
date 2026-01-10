#!/bin/bash
set -e

# SQL command to create the base migrations table
SQL_COMMANDS=$(cat <<EOF

-- DROP TABLE IF EXISTS migrations;

SET client_min_messages TO WARNING;
CREATE TABLE IF NOT EXISTS migrations (
    id TEXT PRIMARY KEY,
    run_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- INSERT INTO migrations (id) VALUES ('test-id') ON CONFLICT DO NOTHING;

EOF
)

psql --single-transaction -c "$SQL_COMMANDS" > /dev/null 2>&1
echo "Database migration table is ready"
