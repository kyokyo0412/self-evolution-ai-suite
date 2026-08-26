#!/usr/bin/env bash
# test-ascii-codex-contracts.sh - Phase 2 contract tests for ASCII cleanliness and Codex adapter
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

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_DIR="$SUITE_ROOT/.ai-suite"

# -------------------------------------------------------------
# Test Suite 1: Codex Adapter Contract Tests
# -------------------------------------------------------------
CODEX_ADAPTER="$SUITE_DIR/layer1-abstraction/agents/codex/adapter.sh"
CORE_LIB="$SUITE_DIR/layer2-cognitive/memory/core.sh"

if [[ -f "$CODEX_ADAPTER" ]]; then
  pass "Codex adapter exists at $CODEX_ADAPTER"
else
  fail "Codex adapter missing"
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Source dependencies in a subshell or directly
source "$CORE_LIB"
source "$CODEX_ADAPTER"

# Test 1.1: Project Install generates AGENTS.md
TEST_PROJ="$TMP_DIR/proj1"
mkdir -p "$TEST_PROJ"

agent_install_project "$SUITE_DIR" "$TEST_PROJ" >/dev/null 2>&1 || true

if [[ -f "$TEST_PROJ/AGENTS.md" ]]; then
  pass "Project install created $TEST_PROJ/AGENTS.md"
else
  fail "Project install failed to create $TEST_PROJ/AGENTS.md"
fi

if [[ -d "$TEST_PROJ/.codex/skills" ]]; then
  pass "Project install created skills dir $TEST_PROJ/.codex/skills"
else
  fail "Project install failed to create $TEST_PROJ/.codex/skills"
fi

if [[ -d "$TEST_PROJ/.codex/meta" ]]; then
  pass "Project install created meta dir $TEST_PROJ/.codex/meta"
else
  fail "Project install failed to create $TEST_PROJ/.codex/meta"
fi

if [[ -f "$TEST_PROJ/AGENTS.md" ]] && grep -q "<!-- ai-suite:start -->" "$TEST_PROJ/AGENTS.md" && grep -q "<!-- ai-suite:end -->" "$TEST_PROJ/AGENTS.md"; then
  pass "AGENTS.md contains ai-suite sentinels"
else
  fail "AGENTS.md missing ai-suite sentinels"
fi

# Verify directives and safety rules are embedded
if [[ -f "$TEST_PROJ/AGENTS.md" ]] && grep -q "Agent General Directives" "$TEST_PROJ/AGENTS.md" && grep -q "Production Safety Guardrails" "$TEST_PROJ/AGENTS.md"; then
  pass "AGENTS.md contains embedded directives and safety rules"
else
  fail "AGENTS.md missing directives or safety rules"
fi

# Test 1.2: Project Uninstall removes block and directories
# Create a dummy legacy .codexrules as well
printf "<!-- ai-suite:start -->\nlegacy\n<!-- ai-suite:end -->\n" > "$TEST_PROJ/.codexrules"

agent_uninstall_project "$TEST_PROJ" >/dev/null 2>&1 || true

if [[ -f "$TEST_PROJ/AGENTS.md" ]] && grep -q "<!-- ai-suite:start -->" "$TEST_PROJ/AGENTS.md"; then
  fail "AGENTS.md still contains ai-suite block after uninstall"
else
  pass "AGENTS.md ai-suite block removed after uninstall"
fi

if [[ -f "$TEST_PROJ/.codexrules" ]] && grep -q "<!-- ai-suite:start -->" "$TEST_PROJ/.codexrules"; then
  fail "Legacy .codexrules still contains ai-suite block after uninstall"
else
  pass "Legacy .codexrules block cleaned up after uninstall"
fi

if [[ -d "$TEST_PROJ/.codex/skills" ]]; then
  fail ".codex/skills still exists after uninstall"
else
  pass ".codex/skills removed after uninstall"
fi

# -------------------------------------------------------------
# Test Suite 2: ASCII Cleanliness Contracts
# -------------------------------------------------------------
NON_ASCII_COUNT=$(python3 -c "
import os

count = 0
for root, dirs, files in os.walk('$SUITE_ROOT'):
    if '.git' in dirs:
        dirs.remove('.git')
    for f in files:
        if f.endswith(('.pyc', '.png', '.jpg', '.jpeg', '.gif', '.webp', '.ico', '.pdf', '.bin')):
            continue
        p = os.path.join(root, f)
        try:
            with open(p, 'rb') as fp:
                data = fp.read()
            if any(b >= 128 for b in data):
                count += 1
        except Exception:
            pass
print(count)
")

if [[ "$NON_ASCII_COUNT" -eq 0 ]]; then
  pass "All files in repository are valid ASCII (non-ASCII file count: 0)"
else
  fail "Files with non-ASCII characters found (count: $NON_ASCII_COUNT)"
fi

printf '\nContract Tests Summary: %d passed, %d failed\n' "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
