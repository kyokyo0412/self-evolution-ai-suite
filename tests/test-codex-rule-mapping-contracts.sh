#!/usr/bin/env bash
# test-codex-rule-mapping-contracts.sh - Contract tests for rule-to-prompt transformation
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

echo "=== Phase 2: Testing Rule-to-Prompt Mapping Contracts ==="

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_DIR="$SUITE_ROOT/.ai-suite"
CORE_LIB="$SUITE_DIR/layer2-cognitive/memory/core.sh"
CODEX_ADAPTER="$SUITE_DIR/layer1-abstraction/agents/codex/adapter.sh"

source "$CORE_LIB"
source "$CODEX_ADAPTER"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TEST_PROJ="$TMP_DIR/proj_rule_test"
mkdir -p "$TEST_PROJ"

# Execute project install for codex
agent_install_project "$SUITE_DIR" "$TEST_PROJ" >/dev/null 2>&1 || true

# Test 1: Check that AGENTS.md exists
if [[ -f "$TEST_PROJ/AGENTS.md" ]]; then
  pass "AGENTS.md created"
else
  fail "AGENTS.md missing"
fi

# Test 2: Check that AGENTS.md does NOT contain raw MDC frontmatter lines
if grep -E -q '^(alwaysApply:|globs:)' "$TEST_PROJ/AGENTS.md"; then
  fail "AGENTS.md contains raw YAML frontmatter lines (alwaysApply or globs)"
else
  pass "AGENTS.md does not contain raw YAML frontmatter lines"
fi

# Test 3 & 4: Check that .codex/rules contains zero markdown files (reserved for Starlark rules)
MD_IN_RULES=0
if [[ -d "$TEST_PROJ/.codex/rules" ]]; then
  MD_IN_RULES=$(find "$TEST_PROJ/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$MD_IN_RULES" -eq 0 ]]; then
  pass ".codex/rules contains zero markdown prompt files (reserved for Starlark execution rules)"
else
  fail ".codex/rules contains $MD_IN_RULES markdown files"
fi

# Test 5: Verify all critical directive and safety content exists in AGENTS.md
for topic in "Agent General Directives" "Master Code Quality" "1E-Class Security Standards" "Production Safety Guardrails"; do
  if grep -q "$topic" "$TEST_PROJ/AGENTS.md"; then
    pass "AGENTS.md correctly mapped: $topic"
  else
    fail "AGENTS.md missing topic: $topic"
  fi
done

printf '\nRule Mapping Contract Tests Summary: %d passed, %d failed\n' "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
