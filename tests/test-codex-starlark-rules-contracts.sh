#!/usr/bin/env bash
# tests/test-codex-starlark-rules-contracts.sh
# Contract tests for Codex Starlark Rules vs AGENTS.md Markdown Migration

set -euo pipefail

PASSED=0
FAILED=0

pass() {
  echo "  [PASS] $1"
  PASSED=$((PASSED + 1))
}

fail() {
  echo "  [FAIL] $1"
  FAILED=$((FAILED + 1))
}

SUITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.ai-suite" && pwd)"
CORE_LIB="$SUITE_DIR/layer2-cognitive/memory/core.sh"
CODEX_ADAPTER="$SUITE_DIR/layer1-abstraction/agents/codex/adapter.sh"

source "$CORE_LIB"
source "$CODEX_ADAPTER"

TEST_PROJ=$(mktemp -d "${TMPDIR:-/tmp}/test_codex_starlark_XXXXXX")
trap 'rm -rf "$TEST_PROJ"' EXIT

echo "=== Phase 2: Testing Codex Starlark Rules vs AGENTS.md Contracts ==="

# Execute project installation
agent_install_project "$SUITE_DIR" "$TEST_PROJ" >/dev/null

# 1. Check AGENTS.md exists and has the sentinel block
if [[ -f "$TEST_PROJ/AGENTS.md" ]] && grep -q "<!-- ai-suite:start -->" "$TEST_PROJ/AGENTS.md"; then
  pass "AGENTS.md exists with ai-suite block"
else
  fail "AGENTS.md missing or does not have ai-suite block"
fi

# 2. Check AGENTS.md contains inlined rules & directives
if grep -q "Agent General Directives" "$TEST_PROJ/AGENTS.md" && \
   grep -q "Master Code Quality" "$TEST_PROJ/AGENTS.md" && \
   grep -q "1E-Class Security Standards" "$TEST_PROJ/AGENTS.md" && \
   grep -q "Production Safety Guardrails" "$TEST_PROJ/AGENTS.md"; then
  pass "AGENTS.md contains all inlined directives and rules"
else
  fail "AGENTS.md missing one or more inlined directives/rules"
fi

# 3. Check AGENTS.md is free of YAML frontmatter headers
if grep -E -q '^(alwaysApply:|globs:)' "$TEST_PROJ/AGENTS.md"; then
  fail "AGENTS.md contains raw YAML frontmatter lines"
else
  pass "AGENTS.md is free of raw YAML frontmatter"
fi

# 4. CRITICAL CONTRACT: .codex/rules must NOT contain any .md or .mdc markdown prompt files
if [[ -d "$TEST_PROJ/.codex/rules" ]]; then
  MD_IN_RULES=$(find "$TEST_PROJ/.codex/rules" -type f \( -name "*.md" -o -name "*.mdc" \) 2>/dev/null || true | wc -l | tr -d ' ')
else
  MD_IN_RULES=0
fi
if [[ "$MD_IN_RULES" -eq 0 ]]; then
  pass "Zero markdown prompt files in .codex/rules (found: $MD_IN_RULES) - reserved for Starlark rules"
else
  fail "Found $MD_IN_RULES markdown prompt files in .codex/rules - markdown rules must be in AGENTS.md only"
fi

# 5. Check other components are populated
for comp in skills meta templates scripts directives; do
  if [[ -d "$TEST_PROJ/.codex/$comp" ]] && [[ $(find "$TEST_PROJ/.codex/$comp" -type f | wc -l) -gt 0 ]]; then
    pass ".codex/$comp populated"
  else
    fail ".codex/$comp missing or empty"
  fi
done

# 6. Execute uninstall and verify clean removal
agent_uninstall_project "$TEST_PROJ" "$SUITE_DIR" >/dev/null

for comp in skills meta templates scripts directives; do
  if [[ ! -d "$TEST_PROJ/.codex/$comp" ]]; then
    pass ".codex/$comp cleanly removed after uninstall"
  else
    fail ".codex/$comp still exists after uninstall"
  fi
done

if ! grep -q "<!-- ai-suite:start -->" "$TEST_PROJ/AGENTS.md" 2>/dev/null; then
  pass "AGENTS.md block cleanly stripped after uninstall"
else
  fail "AGENTS.md still has ai-suite block after uninstall"
fi

echo ""
echo "Contract Tests Result: $PASSED passed, $FAILED failed"

if [[ "$FAILED" -gt 0 ]]; then
  exit 1
fi
