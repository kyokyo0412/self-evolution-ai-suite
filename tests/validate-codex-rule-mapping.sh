#!/usr/bin/env bash
# validate-codex-rule-mapping.sh - Phase 1 requirements validation for Codex rule mapping
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

echo "=== Phase 1: Validating Requirements for Codex Rule Prompt Mapping ==="

FEATURE_FILE="tests/codex-rule-mapping.feature"

if [[ -f "$FEATURE_FILE" ]]; then
  pass "Feature file $FEATURE_FILE exists"
else
  fail "Feature file $FEATURE_FILE missing"
fi

for scenario in \
  "Scenario: Rules inlined into AGENTS.md are formatted as clean prompt instructions without YAML frontmatter" \
  "Scenario: Mirrored rules in .codex/rules are clean Markdown files (.md)" \
  "Scenario: Multi-agent prompt generation preserves clean formatting"; do
  if grep -qF "$scenario" "$FEATURE_FILE"; then
    pass "Found scenario: $scenario"
  else
    fail "Missing scenario: $scenario"
  fi
done

for kw in "clean prompt instructions" "without YAML frontmatter" ".codex/rules" "clean Markdown files" "Multi-agent prompt"; do
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
