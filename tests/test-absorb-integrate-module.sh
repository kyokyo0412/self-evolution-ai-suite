#!/usr/bin/env bash
# tests/test-absorb-integrate-module.sh -- TDD Module 4 Test Suite: Absorb & Integrate Capabilities
set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$SUITE_ROOT/ai-suite"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== TDD Module 4: Absorb & Integrate Capabilities & Isolation Invariants ==="

ABSORB_SKILL="$SUITE_ROOT/.ai-suite/layer4-evolutionary/merging/absorb-capability.md"
INTEGRATE_SKILL="$SUITE_ROOT/.ai-suite/layer4-evolutionary/merging/integrate-capability.md"

# Test 1: Validate skill frontmatter and compliance with validate-suite.sh
if bash "$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" "$ABSORB_SKILL" >/dev/null 2>&1; then
  pass "Absorb: frontmatter and structure validated by validate-suite.sh"
else
  fail "Absorb: frontmatter validation failed"
fi

if bash "$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" "$INTEGRATE_SKILL" >/dev/null 2>&1; then
  pass "Integrate: frontmatter and structure validated by validate-suite.sh"
else
  fail "Integrate: frontmatter validation failed"
fi

# Test 2: Verify Self-Evolution is explicitly marked as highest priority in both skills
if grep -qi "Self-Evolution Priority" "$ABSORB_SKILL" || grep -qi "Self Evolution Priority" "$ABSORB_SKILL"; then
  pass "Absorb: self-evolution priority rule present"
else
  fail "Absorb: missing self-evolution priority rule"
fi

if grep -qi "Self-Evolution Priority" "$INTEGRATE_SKILL" || grep -qi "Self Evolution Priority" "$INTEGRATE_SKILL"; then
  pass "Integrate: self-evolution priority rule present"
else
  fail "Integrate: missing self-evolution priority rule"
fi

# Test 3: Verify Developing Agent Isolation Invariants
if grep -qi "AI suite developing agent" "$ABSORB_SKILL" && grep -qi "\.ai-suite/" "$ABSORB_SKILL"; then
  pass "Absorb: developing agent isolation and dual-merge invariant specified"
else
  fail "Absorb: developing agent isolation invariant missing"
fi

if grep -qi "AI suite developing agent" "$INTEGRATE_SKILL" && grep -qi "\.ai-suite/" "$INTEGRATE_SKILL"; then
  pass "Integrate: developing agent isolation and source restriction specified"
else
  fail "Integrate: developing agent isolation invariant missing"
fi

# Test 4: CLI workflow commands for absorb and integrate delegate properly
WORKFLOW_ABSORB=$(bash "$SUITE_CLI" workflow absorb --dry-run 2>&1 || true)
if echo "$WORKFLOW_ABSORB" | grep -qi "absorb"; then
  pass "Workflow: absorb command dry-run operates correctly"
else
  fail "Workflow: absorb command failed in dry-run"
fi

WORKFLOW_INTEGRATE=$(bash "$SUITE_CLI" workflow integrate --dry-run 2>&1 || true)
if echo "$WORKFLOW_INTEGRATE" | grep -qi "integrate"; then
  pass "Workflow: integrate command dry-run operates correctly"
else
  fail "Workflow: integrate command failed in dry-run"
fi

total=$((PASS+FAIL))
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[module-4-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[module-4-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
