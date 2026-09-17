#!/usr/bin/env bash
set -euo pipefail

# test-cross-module-regression-closure.sh
# End-to-end integration and regression closure for all AI suite enhancements.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PASS=0
FAIL=0

pass() {
  PASS=$((PASS + 1))
  printf '  \033[32mPASS\033[0m %s\n' "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  printf '  \033[31mFAIL\033[0m %s\n' "$1" >&2
}

echo "=== [SDET Integration Gate] Running Cross-Module Regression Closure ==="

TESTS=(
  "tests/test-ai-suite-cli.sh"
  "tests/test-code-formatting-unit.sh"
  "tests/test-code-quality-enhancement-contracts.sh"
  "tests/test-tdd-team-code-quality-contracts.sh"
  "tests/test-reviewer-code-quality-contracts.sh"
  "tests/test-nuclear-safety-contracts.sh"
  "tests/test-find-and-local-suite-contracts.sh"
  "tests/test-multi-agent-code-quality-harmony.sh"
  "tests/test-prompt-compiler-code-quality-contracts.sh"
  "tests/test-anti-red-flag-clean-whitespace-contracts.sh"
  "tests/test-directives-structural-contracts.sh"
  "tests/test-safety-rules-structural-contracts.sh"
  "tests/test-core-skills-structural-contracts.sh"
  "tests/test-domain-skills-structural-contracts.sh"
  "tests/test-cognitive-templates-structural-contracts.sh"
  "tests/test-agent-adapters-structural-contracts.sh"
  "tests/test-evolutionary-validation-structural-contracts.sh"
  "tests/test-tdd-team-principal-coding-review-contracts.sh"
  "tests/test-tdd-team-principal-coding-review-eut.sh"
)

for t in "${TESTS[@]}"; do
  if bash "$ROOT_DIR/$t" >/dev/null 2>&1; then
    pass "Suite $t completed successfully"
  else
    fail "Suite $t failed"
  fi
done

# CLI subcommands smoke test
if "$ROOT_DIR/ai-suite" --help >/dev/null 2>&1; then
  pass "ai-suite --help succeeds"
else
  fail "ai-suite --help failed"
fi

if "$ROOT_DIR/ai-suite" manage --help >/dev/null 2>&1; then
  pass "ai-suite manage --help succeeds"
else
  fail "ai-suite manage --help failed"
fi

# Full suite schema & integrity validation
if bash "$ROOT_DIR/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" >/dev/null 2>&1; then
  pass "validate-suite.sh completed with 0 errors"
else
  fail "validate-suite.sh reported errors"
fi

echo "Summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
