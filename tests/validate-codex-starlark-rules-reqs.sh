#!/usr/bin/env bash
# tests/validate-codex-starlark-rules-reqs.sh
# Phase 1: Requirements validation script for Codex Starlark Rules vs AGENTS.md migration

set -euo pipefail

PASS=0
FAIL=0

pass() {
  echo "  [PASS] $1"
  PASS=$((PASS + 1))
}

fail() {
  echo "  [FAIL] $1"
  FAIL=$((FAIL + 1))
}

FEATURE_FILE="tests/codex-starlark-rules-migration.feature"

echo "=== Phase 1: Validating Requirements for Codex Starlark Rules vs AGENTS.md Migration ==="

if [[ -f "$FEATURE_FILE" ]]; then
  pass "Feature file $FEATURE_FILE exists"
else
  fail "Feature file $FEATURE_FILE not found"
fi

# Validate scenarios
scenarios=(
  "Scenario: Migration of all markdown rules into AGENTS.md prompt file"
  "Scenario: Zero markdown prompt rules in .codex/rules directory"
  "Scenario: Complete installation of other AI Suite components for Codex"
  "Scenario: Clean uninstallation of Codex components"
  "Scenario: Published package installation domain isolation"
)

for sc in "${scenarios[@]}"; do
  if grep -F -q "$sc" "$FEATURE_FILE"; then
    pass "Found scenario: $sc"
  else
    fail "Missing scenario: $sc"
  fi
done

# Validate key architectural requirements
keywords=(
  "Starlark"
  "AGENTS.md"
  ".codex/rules"
  "templates"
  "scripts"
  "directives"
  "skills"
  "VMware or Broadcom"
)

for kw in "${keywords[@]}"; do
  if grep -F -q "$kw" "$FEATURE_FILE"; then
    pass "Requirement keyword verified: $kw"
  else
    fail "Missing requirement keyword: $kw"
  fi
done

echo ""
echo "Requirements Validation Result: $PASS passed, $FAIL failed"

if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
