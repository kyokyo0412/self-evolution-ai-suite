#!/usr/bin/env bash
# validate-ascii-codex-requirements.sh - Phase 1 requirements validation
set -euo pipefail

PASS=0
FAIL=0

pass() {
  printf '[PASS] %s\n' "$1"
  PASS=$((PASS + 1))
}

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  FAIL=$((FAIL + 1))
}

FEATURE_FILE="tests/ascii-codex-enhancement.feature"

# Check 1: Feature file exists
if [[ -f "$FEATURE_FILE" ]]; then
  pass "Feature file $FEATURE_FILE exists"
else
  fail "Feature file $FEATURE_FILE missing"
fi

# Check 2: Feature file contains required Gherkin scenarios
for scenario in \
  "Scenario: All files across the AI Suite and tests are strictly valid ASCII" \
  "Scenario: Codex Agent installs project-level instructions into AGENTS.md" \
  "Scenario: Codex Agent installs global instructions into ~/.codex/AGENTS.md" \
  "Scenario: Codex Agent uninstalls cleanly from project and global scopes" \
  "Scenario: Multi-agent compatibility is preserved"; do
  if grep -qF "$scenario" "$FEATURE_FILE"; then
    pass "Found scenario: $scenario"
  else
    fail "Missing scenario: $scenario"
  fi
done

# Check 3: BVA and Equivalence checks in requirements
# Equivalence Classes:
# 1. Project scope vs Global scope installation
# 2. Codex agent vs other agents (Cursor, Claude, OpenCode, Continue, Roo-Code)
# 3. File types (scripts .sh, markdown .md, mdc .mdc, typescript .d.ts, feature files .feature)
# Negative / Edge paths:
# 1. Legacy .codexrules cleanup during disable
# 2. Existing pre-content in AGENTS.md preserved when installing/uninstalling
# 3. Handling files with missing or corrupted encodings

for kw in "AGENTS.md" "<!-- ai-suite:start -->" "<!-- ai-suite:end -->" "directives" "safety rules" "cleanly"; do
  if grep -qF "$kw" "$FEATURE_FILE"; then
    pass "Requirement keyword verified: $kw"
  else
    fail "Requirement keyword missing: $kw"
  fi
done

printf '\nRequirements Validation Summary: %d passed, %d failed\n' "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
