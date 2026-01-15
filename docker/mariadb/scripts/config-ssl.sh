#!/bin/sh
set -e

# Create SSL configuration file
cat > "/etc/mysql/conf.d/1-server-ssl.cnf" <<'EOF'
[mariadbd]
ssl-ca=/etc/mysql/conf.d/ca.pem
ssl-cert=/etc/mysql/conf.d/server.pem
ssl-key=/etc/mysql/conf.d/server.key
EOF
