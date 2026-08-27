#!/usr/bin/env bash
# test-codex-full-install-contracts.sh - Phase 2 contract tests for Codex full installation
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

echo "=== Phase 2: Testing Codex Full Installation Contracts ==="

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_DIR="$SUITE_ROOT/.ai-suite"
CODEX_ADAPTER="$SUITE_DIR/layer1-abstraction/agents/codex/adapter.sh"
CORE_LIB="$SUITE_DIR/layer2-cognitive/memory/core.sh"

if [[ ! -f "$CODEX_ADAPTER" ]]; then
  fail "Codex adapter missing at $CODEX_ADAPTER"
  exit 1
fi

source "$CORE_LIB"
source "$CODEX_ADAPTER"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TEST_PROJ="$TMP_DIR/proj_test"
mkdir -p "$TEST_PROJ"

# Execute project install
agent_install_project "$SUITE_DIR" "$TEST_PROJ" >/dev/null 2>&1 || true

# Test 1: Instruction file AGENTS.md exists and contains AI suite sentinels
if [[ -f "$TEST_PROJ/AGENTS.md" ]] && grep -q "<!-- ai-suite:start -->" "$TEST_PROJ/AGENTS.md"; then
  pass "AGENTS.md exists with ai-suite block"
else
  fail "AGENTS.md missing or does not have start sentinel"
fi

# Test 2: Skills directory populated
if [[ -d "$TEST_PROJ/.codex/skills" ]] && [[ -n "$(ls -A "$TEST_PROJ/.codex/skills" 2>/dev/null)" ]]; then
  pass ".codex/skills populated"
else
  fail ".codex/skills missing or empty"
fi

# Test 3: Meta directory populated
if [[ -d "$TEST_PROJ/.codex/meta" ]] && [[ -n "$(ls -A "$TEST_PROJ/.codex/meta" 2>/dev/null)" ]]; then
  pass ".codex/meta populated"
else
  fail ".codex/meta missing or empty"
fi

# Test 4: Templates directory populated
if [[ -d "$TEST_PROJ/.codex/templates" ]] && [[ -n "$(ls -A "$TEST_PROJ/.codex/templates" 2>/dev/null)" ]]; then
  pass ".codex/templates populated"
else
  fail ".codex/templates missing or empty"
fi

# Test 5: Scripts directory populated
if [[ -d "$TEST_PROJ/.codex/scripts" ]] && [[ -n "$(ls -A "$TEST_PROJ/.codex/scripts" 2>/dev/null)" ]]; then
  pass ".codex/scripts populated"
else
  fail ".codex/scripts missing or empty"
fi

# Test 6: Rules directory does NOT contain markdown prompt rules (reserved for Starlark execution rules)
MD_IN_RULES=0
if [[ -d "$TEST_PROJ/.codex/rules" ]]; then
  MD_IN_RULES=$(find "$TEST_PROJ/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null | wc -l | tr -d ' ')
fi
if [[ "$MD_IN_RULES" -eq 0 ]]; then
  pass ".codex/rules contains zero markdown files (reserved for Starlark execution rules)"
else
  fail ".codex/rules contains $MD_IN_RULES markdown files"
fi

# Test 7: Directives directory populated
if [[ -d "$TEST_PROJ/.codex/directives" ]] && [[ -n "$(ls -A "$TEST_PROJ/.codex/directives" 2>/dev/null)" ]]; then
  pass ".codex/directives populated"
else
  fail ".codex/directives missing or empty"
fi

# Test 8: AGENTS.md contains full directives, code-quality, nuclear-safety, production-safety
for keyword in "Agent General Directives" "Master Code Quality" "1E-Class Security Standards" "Production Safety Guardrails"; do
  if grep -q "$keyword" "$TEST_PROJ/AGENTS.md"; then
    pass "AGENTS.md contains $keyword"
  else
    fail "AGENTS.md missing $keyword"
  fi
done

# Test 9: Uninstall removes all installed directories and sentinels cleanly
agent_uninstall_project "$TEST_PROJ" "$SUITE_DIR" >/dev/null 2>&1 || true

for dir in skills meta templates scripts directives; do
  if [[ -d "$TEST_PROJ/.codex/$dir" ]]; then
    fail ".codex/$dir still exists after uninstall"
  else
    pass ".codex/$dir cleanly removed after uninstall"
  fi
done

if grep -q "<!-- ai-suite:start -->" "$TEST_PROJ/AGENTS.md" 2>/dev/null; then
  fail "AGENTS.md still has ai-suite block after uninstall"
else
  pass "AGENTS.md block cleanly stripped after uninstall"
fi

printf '\nContract Tests Result: %d passed, %d failed\n' "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
