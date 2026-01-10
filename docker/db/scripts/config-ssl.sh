#!/bin/sh
set -e

# Append SSL configuration to postgresql.conf
echo "ssl = on" >> "$PGDATA/postgresql.conf"
echo "ssl_cert_file = '/certs/server.pem'" >> "$PGDATA/postgresql.conf"
echo "ssl_key_file = '/certs/server.key'" >> "$PGDATA/postgresql.conf"
echo "ssl_ca_file = '/certs/ca.pem'" >> "$PGDATA/postgresql.conf"

# Allow SSL connections only
echo "local all all trust" > "$PGDATA/pg_hba.conf"
echo "hostssl all all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
echo "hostssl all all ::/0 md5" >> "$PGDATA/pg_hba.conf"
