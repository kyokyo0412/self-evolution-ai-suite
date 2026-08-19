#!/usr/bin/env bash
set -euo pipefail

echo "Running Phase 2 validation for cleanup-redundant-agents-contracts.md..."

if [[ ! -f "tests/cleanup-redundant-agents-contracts.md" ]]; then
  echo "FAIL: Contracts file not found."
  exit 1
fi

if ! grep -q "The following directories MUST NOT exist" "tests/cleanup-redundant-agents-contracts.md"; then
  echo "FAIL: Contracts file missing required directory constraints."
  exit 1
fi

echo "PASS: Phase 2 validation successful."
exit 0
