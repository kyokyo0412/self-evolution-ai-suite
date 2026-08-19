#!/usr/bin/env bash
set -euo pipefail

echo "Running End-to-End System QA Gate for cleanup-redundant-agents..."

FAIL=0

# Check if redundant directories exist
for dir in .roo .continue .opencode .claude; do
  if [[ -d "$dir" ]]; then
    echo "FAIL: Redundant directory $dir exists."
    FAIL=1
  fi
done

for file in CLAUDE.md .roorules; do
  if [[ -f "$file" ]]; then
    echo "FAIL: Redundant file $file exists."
    FAIL=1
  fi
done

if [[ ! -d ".cursor" ]]; then
  echo "FAIL: .cursor directory is missing."
  FAIL=1
fi

if [[ ! -f ".cursorrules" ]]; then
  echo "FAIL: .cursorrules file is missing."
  FAIL=1
fi

if [[ $FAIL -eq 1 ]]; then
  echo "FAIL: Redundant agents cleanup failed."
  exit 1
fi

echo "PASS: All cleanup tests passed."
exit 0
