#!/bin/bash
set -e
export PGPASSWORD="${DB_PASSWORD:-${PGPASSWORD:-}}"
if [ -z "$PGPASSWORD" ]; then
    echo "Error: DB_PASSWORD environment variable is not set."
    exit 1
fi
echo "Resetting the 'schooldb' database..."
psql -h 127.0.0.1 -U postgres -d schooldb -f bootstrap.sql -v ON_ERROR_STOP=1
echo "BOOTSTRAP OK"