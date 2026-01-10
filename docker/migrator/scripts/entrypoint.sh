#!/bin/bash
set -e

# Setup database environment
source ./env.sh

# Bootstrap the migrations database table
./bootstrap.sh

# Run migrations
./run.sh

echo "Database migration successfully completed"
