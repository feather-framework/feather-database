#!/bin/bash
set -e

export PGHOST=$DATABASE_HOST \
    PCPORT=$DATABASE_PORT \
    PGUSER=$DATABASE_USER \
    PGPASSWORD=$DATABASE_PASSWORD \
    PGDATABASE=$DATABASE_NAME

# Wait for the database connection
until env PGDATABASE=postgres pg_isready; do
    echo "$(date) - waiting for postgres...on $POSTGRES_HOST:$POSTGRES_PORT"
    sleep 1
done
