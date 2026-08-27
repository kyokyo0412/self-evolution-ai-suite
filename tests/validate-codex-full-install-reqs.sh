#!/usr/bin/env bash
# validate-codex-full-install-reqs.sh - Phase 1 requirements validation for Codex full install
set -euo pipefail

PASS=0
FAIL=0

pass() {
  printf '  [PASS] %s\n' "$1"
  PASS=$((PASS + 1))
}

fail() {
  printf '  [FAIL] %s\n' "$1" >&2
  FAIL=$((FAIL + 1))
}

echo "=== Phase 1: Validating Requirements for Codex Full Installation ==="

FEATURE_FILE="tests/codex-full-install.feature"

# Check 1: Feature file exists
if [[ -f "$FEATURE_FILE" ]]; then
  pass "Feature file $FEATURE_FILE exists"
else
  fail "Feature file $FEATURE_FILE missing"
fi

# Check 2: Verify all scenarios
for scenario in \
  "Scenario: Project-scope Codex enable installs all components" \
  "Scenario: Global-scope Codex enable installs all components" \
  "Scenario: Project and Global uninstallation cleanly removes all installed components" \
  "Scenario: Installation from a published package contains zero VMware or Broadcom domain assets"; do
  if grep -qF "$scenario" "$FEATURE_FILE"; then
    pass "Found scenario: $scenario"
  else
    fail "Missing scenario: $scenario"
  fi
done

# Check 3: Check coverage of key requirement concepts
for kw in "templates" "directives" "rules" "scripts" "AGENTS.md" "published package" "VMware or Broadcom"; do
  if grep -qF "$kw" "$FEATURE_FILE"; then
    pass "Requirement keyword verified: $kw"
  else
    fail "Requirement keyword missing: $kw"
  fi
done

printf '\nRequirements Validation Result: %d passed, %d failed\n' "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
