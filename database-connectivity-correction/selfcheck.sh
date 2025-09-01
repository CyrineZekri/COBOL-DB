#!/usr/bin/env bash
set -euo pipefail

red(){ printf "\033[31m%s\033[0m\n" "$*"; }
grn(){ printf "\033[32m%s\033[0m\n" "$*"; }
ylw(){ printf "\033[33m%s\033[0m\n" "$*"; }

step(){ ylw "\n== $* =="; }

# 1) Toolchain
step "Toolchain versions"
cobc -v | head -n 1
gcc --version | head -n 1
psql --version

# 2) DB availability
step "PostgreSQL connectivity"
PGPASSWORD="${DB_PASSWORD:-postgres}" psql -h 127.0.0.1 -U postgres -d postgres -c "SELECT 1;" >/dev/null \
  && grn "OK psql works" || { red "psql connection failed"; exit 1; }

# 3) Seed database
step "Seeding schooldb (idempotent)"
DB_PASSWORD="${DB_PASSWORD:-postgres}" ./reset_db.sh

# 4) Schema presence
step "Checking schema/tables"
PGPASSWORD="${DB_PASSWORD:-postgres}" psql -h 127.0.0.1 -U postgres -d schooldb -Atqc \
"SELECT 'customers' FROM information_schema.tables
 WHERE table_schema='bank' AND table_name='customers'
 UNION ALL
 SELECT 'accounts'  FROM information_schema.tables
 WHERE table_schema='bank' AND table_name='accounts';" | sort > /tmp/_tbls.txt

if diff -u <(printf "accounts\ncustomers\n") /tmp/_tbls.txt; then
  grn "OK schema bank with accounts/customers"
else
  red "Missing expected tables"; exit 1
fi

# 5) Build wrapper & COBOL
step "Building wrapper + COBOL"
test -f lib/libpgcob.so || gcc -shared -fPIC -o lib/libpgcob.so db_wrapper.c -I/usr/include/postgresql -lpq
make -s

# 6) SO dependency check
step "Checking lib dependencies"
ldd lib/libpgcob.so | grep -E "libpq|libc" || { red "ldd missing libpq"; exit 1; }

# 7) Run smoke
step "Running smoke"
if ./build/smoke; then
  grn "OK smoke"
else
  red "Smoke failed"; exit 1
fi

grn "\nALL CHECKS PASSED ✅  Skeleton is ready for students."
