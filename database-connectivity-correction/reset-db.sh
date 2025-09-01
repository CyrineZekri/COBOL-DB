#!/usr/bin/env bash
set -euo pipefail

DB_NAME=${DB_NAME:-schooldb}
SQL_FILE=${SQL_FILE:-bootstrap.sql}

# teach psql to use a password if passed as DB_PASSWORD (or already set PGPASSWORD)
export PGPASSWORD="${DB_PASSWORD:-${PGPASSWORD:-}}"

# Create DB if missing (idempotent)
createdb -h 127.0.0.1 -U postgres "$DB_NAME" 2>/dev/null || true

# Load schema + seed
psql -h 127.0.0.1 -U postgres -d "$DB_NAME" -f "$SQL_FILE"

echo "BOOTSTRAP OK"
