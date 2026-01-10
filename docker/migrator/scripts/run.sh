#!/bin/bash
set -e

for filepath in ./migrations/*.sql; do
    filename=$(basename -- "$filepath")
    migration_id="${filename%.*}"
    migration_check="SELECT 1 FROM migrations WHERE id = '$migration_id' LIMIT 1;"
    migration_exists=$(psql -A -t -c "$migration_check")

    if [[ -z "$migration_exists" ]]; then
        echo "Running migration: $migration_id"
        if psql --single-transaction -f "$filepath"; then
            psql -c "INSERT INTO migrations (id) VALUES ('$migration_id');"
        else
            echo "Failed to run migration $migration_id — stopping"
            exit 1
        fi
    else
        echo "Skipping migration: $migration_id"
    fi
done
