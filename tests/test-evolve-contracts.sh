#!/usr/bin/env bash
# test-evolve-contracts.sh - Phase 2 contract tests.
# Verifies the interface contracts in evolve-contracts.md against ai-suite evolve.
# Runs in a temporary sandbox; never touches the real $HOME.
# Usage: bash tests/test-evolve-contracts.sh

set -uo pipefail
SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$SUITE_ROOT/ai-suite"

# -- helpers ------------------------------------------------------------------
PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }
assert_exit() {
  local label="$1" expected="$2"; shift 2
  local actual
  "$@" >/dev/null 2>&1; actual=$?
  if [[ "$actual" -eq "$expected" ]]; then
    pass "$label (exit $actual)"
  else
    fail "$label - expected exit $expected, got $actual"
  fi
}
assert_output_contains() {
  local label="$1" needle="$2"; shift 2
  local out
  out=$("$@" 2>&1 || true)
  if printf '%s' "$out" | grep -qF -- "$needle"; then
    pass "$label"
  else
    fail "$label - output did not contain: $needle"
  fi
}

echo "=== Phase 2 Contract Tests: ai-suite evolve ==="

# -- C0: script exists and is executable -------------------------------------
if [[ -f "$SCRIPT" ]]; then
  pass "C0a: script file exists"
else
  fail "C0a: ai-suite evolve not found at $SCRIPT"
fi

if [[ -x "$SCRIPT" ]]; then
  pass "C0b: script is executable"
else
  fail "C0b: ai-suite evolve is not executable"
fi

# -- C0c: bash -n (syntax check) ---------------------------------------------
if bash -n "$SCRIPT" 2>/dev/null; then
  pass "C0c: bash -n syntax OK"
else
  fail "C0c: bash -n reports syntax errors"
fi

# -- C1: collect without --host exits non-zero with message -------------------
assert_exit   "C1a: collect no --host -> non-zero" 1 \
  "$SCRIPT" evolve collect

assert_output_contains "C1b: collect no --host -> error mentions --host" "--host" \
  "$SCRIPT" evolve collect

# -- P1: push without --host exits non-zero -----------------------------------
assert_exit "P1a: push no --host -> non-zero" 1 \
  "$SCRIPT" evolve push

assert_output_contains "P1b: push no --host -> error mentions --host" "--host" \
  "$SCRIPT" evolve push

# -- Unknown sub-command ------------------------------------------------------
assert_exit "U1: unknown sub-command exits non-zero" 1 \
  "$SCRIPT" evolve bogus

# -- --help / no args ---------------------------------------------------------
# Should print usage and exit 0
assert_exit "H1: no args shows usage exit 0" 0 \
  "$SCRIPT" evolve

assert_output_contains "H2: --help shows 'collect'" "collect" \
  "$SCRIPT" evolve --help

assert_output_contains "H3: --help shows 'push'" "push" \
  "$SCRIPT" evolve --help

# -- C8/P6: --dry-run flag accepted without error (host is unreachable, which
#           is fine because dry-run must not actually connect) -----------------
# Use a clearly-unreachable address; dry-run must not attempt SSH.
assert_exit "C8: collect --dry-run --host fake exits 0" 0 \
  "$SCRIPT" evolve collect --host "testuser@192.0.2.1" --dry-run

assert_output_contains "C8b: collect --dry-run mentions DRY" "DRY" \
  "$SCRIPT" evolve collect --host "testuser@192.0.2.1" --dry-run

assert_exit "P6: push --dry-run --host fake exits 0" 0 \
  "$SCRIPT" evolve push --host "testuser@192.0.2.1" --dry-run

assert_output_contains "P6b: push --dry-run mentions DRY" "DRY" \
  "$SCRIPT" evolve push --host "testuser@192.0.2.1" --dry-run

if "$SCRIPT" evolve push --host "testuser@192.0.2.1" --dry-run 2>&1 | grep -q -- "--delete"; then
  fail "P4: push rsync contains --delete, which disables merge behavior"
else
  pass "P4: push rsync does not contain --delete"
fi

# -- C2/P2: Default --remote-path contains '$HOME' literally (must be a string,
#           not the local home expansion) ------------------------------------
DEFAULT_PATH_OUTPUT=$("$SCRIPT" evolve push --host "testuser@192.0.2.1" --dry-run 2>&1 || true)
# shellcheck disable=SC2016  # intentional: searching for the literal string '$HOME'
if echo "$DEFAULT_PATH_OUTPUT" | grep -qE '\$HOME|ai-suite-deploy'; then
  pass "C2/P2: default remote-path contains \$HOME or ai-suite-deploy"
else
  fail "C2/P2: default remote-path not shown in dry-run output"
fi

# -- Summary ------------------------------------------------------------------
printf '\n'
total=$((PASS+FAIL))
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[contract-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[contract-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
