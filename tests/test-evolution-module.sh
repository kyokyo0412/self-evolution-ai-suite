#!/usr/bin/env bash
# tests/test-evolution-module.sh -- TDD Module 3 Test Suite: Self-Evolution Functionality
set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$SUITE_ROOT/ai-suite"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== TDD Module 3: Self-Evolution Framework & Local/Remote Collection ==="

TMP_SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/tdd-evolution.XXXXXX")
trap 'rm -rf "$TMP_SANDBOX"' EXIT

MOCK_HOME="$TMP_SANDBOX/mock_home"
mkdir -p "$MOCK_HOME/.cursor/skills/mock-skill"

cat > "$MOCK_HOME/.cursor/skills/mock-skill/SKILL.md" << 'EOF'
---
name: mock-skill
description: Mock skill for testing self-evolution local collect. Use when testing evolution.
triggers:
  - mock skill
---

# Mock Skill
Instructions for mock skill.

## Instructions
1. Step 1

## Negative Constraints
- None
EOF

# Test 1: Dry run of local collect
HOME="$MOCK_HOME" bash "$SUITE_CLI" evolve collect --local --dry-run >/dev/null
pass "Evolve: dry-run collect --local succeeded"

# Test 2: Execute evolve collect --local and verify changes are collected into .ai-suite
HOME="$MOCK_HOME" bash "$SUITE_CLI" evolve collect --local >/dev/null

if [[ -f "$SUITE_ROOT/.ai-suite/layer1-abstraction/agents/cursor/skills/mock-skill.md" ]]; then
  pass "Evolve: mock-skill collected into .ai-suite"
  # Cleanup mock skill
  rm -f "$SUITE_ROOT/.ai-suite/layer1-abstraction/agents/cursor/skills/mock-skill.md"
else
  fail "Evolve: mock-skill was not collected into .ai-suite"
fi

# Test 3: Verify evolution report was generated
REPORT_COUNT=$(find "$SUITE_ROOT/.ai-suite/layer4-evolutionary/reflection/evolutions" -maxdepth 1 -name "evolution_report_local_*.md" -o -name "*_local_*.md" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$REPORT_COUNT" -gt 0 ]]; then
  pass "Evolve: evolution report written to evolutions/"
  find "$SUITE_ROOT/.ai-suite/layer4-evolutionary/reflection/evolutions" -maxdepth 1 -name "evolution_report_local_*.md" -delete 2>/dev/null || true
else
  fail "Evolve: evolution report missing"
fi

# Test 4: Verify push does NOT perform local collection
if grep -A 20 "do_push()" "$SUITE_ROOT/.ai-suite/cli/evolve.sh" | grep -q "COLLECT_LOCAL"; then
  fail "Evolve: do_push still contains misplaced COLLECT_LOCAL logic"
else
  pass "Evolve: do_push is clean of local collection logic"
fi

total=$((PASS+FAIL))
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[module-3-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[module-3-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
