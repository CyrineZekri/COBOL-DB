#!/usr/bin/env bash
set -euo pipefail
mkdir -p build
for b in smoke 0_verify_env 1_verify_schema 2_verify_select 3_verify_error 4_verify_logging 5_verify_end_to_end; do
  if [[ -x "build/$b" ]]; then
    echo "=== $b ==="
    "./build/$b" | tee "build/$b.out" || true
  fi
done
