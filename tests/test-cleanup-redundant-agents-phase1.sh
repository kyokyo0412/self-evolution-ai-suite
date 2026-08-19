#!/usr/bin/env bash
set -euo pipefail

echo "Running Phase 1 validation for cleanup-redundant-agents.feature..."

if [[ ! -f "tests/cleanup-redundant-agents.feature" ]]; then
  echo "FAIL: Feature file not found."
  exit 1
fi

if ! grep -q "Feature: Cleanup Redundant Agent Configurations" "tests/cleanup-redundant-agents.feature"; then
  echo "FAIL: Feature file missing required feature description."
  exit 1
fi

echo "PASS: Phase 1 validation successful."
exit 0
