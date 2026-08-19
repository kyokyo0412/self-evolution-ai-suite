#!/usr/bin/env bash
# test-global-cursorrules-contracts.sh — Phase 2 RED contract tests
# Verifies cursor/adapter.sh satisfies the global-cursorrules contracts.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ADAPTER="$PROJECT_ROOT/.ai-suite/layer1-abstraction/agents/cursor/adapter.sh"
SUITE_DIR="$PROJECT_ROOT/.ai-suite"

PASS=0; FAIL=0

pass() { printf '  \033[32mPASS\033[0m  %s\n' "$1"; PASS=$((PASS+1)); }
fail() { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; FAIL=$((FAIL+1)); }

check_contains() {
  local label="$1"; local pattern="$2"
  if grep -qE -- "$pattern" "$ADAPTER"; then pass "$label"
  else fail "$label — pattern not found: $pattern"; fi
}

# ── C1: Static source contracts ───────────────────────────────────────────────
echo ""
echo "=== C1: Static source contracts ==="

check_contains "C1a _append_cursorrules_global_block function defined" \
  "_append_cursorrules_global_block\(\)"

check_contains "C1b _append_cursorrules_global_block writes to HOME/.cursorrules" \
  'HOME.*\.cursorrules|cursorrules.*HOME'

check_contains "C1c _append_cursorrules_global_block calls _remove_cursorrules_block" \
  "_remove_cursorrules_block"

check_contains "C1d _append_cursorrules_global_block references suite_dir/meta" \
  'meta_dir|suite_dir.*meta|meta.*suite'

check_contains "C1e _append_cursorrules_global_block references ~/.cursor/skills" \
  'cursor/skills|\$HOME.*cursor.*skills'

check_contains "C1f agent_install_global calls _append_cursorrules_global_block" \
  "_append_cursorrules_global_block"

check_contains "C1g agent_uninstall_global calls _remove_cursorrules_block on HOME/.cursorrules" \
  '_remove_cursorrules_block.*HOME|HOME.*cursorrules.*_remove|_remove_cursorrules_block.*cursorrules'

# ── C2: Functional sandbox tests ─────────────────────────────────────────────
echo ""
echo "=== C2: Functional sandbox tests ==="

SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/global-cr-contracts.XXXXXX")
trap 'rm -rf "$SANDBOX"' EXIT

(
  export HOME="$SANDBOX"
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
  source "$ADAPTER"
  agent_install_global "$SUITE_DIR"
)

CR="$SANDBOX/.cursorrules"

if [[ -f "$CR" ]]; then
  pass "C2a ~/.cursorrules created by agent_install_global"
else
  fail "C2a ~/.cursorrules created by agent_install_global"
fi

if grep -q '>>>>> cursor-ai-suite >>>>>' "$CR" 2>/dev/null; then
  pass "C2b AI Suite block start marker present in ~/.cursorrules"
else
  fail "C2b AI Suite block start marker present in ~/.cursorrules"
fi

if grep -q 'reflection-protocol.md' "$CR" 2>/dev/null; then
  pass "C2c reflection-protocol.md path referenced in ~/.cursorrules"
else
  fail "C2c reflection-protocol.md path referenced in ~/.cursorrules"
fi

if grep -q '\.cursor/skills\|cursor/skills' "$CR" 2>/dev/null; then
  pass "C2d skills location referenced in ~/.cursorrules"
else
  fail "C2d skills location referenced in ~/.cursorrules"
fi

# C2e: idempotency — run again, count block starts
(
  export HOME="$SANDBOX"
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
  source "$ADAPTER"
  agent_install_global "$SUITE_DIR"
)
block_count=$(grep -c '>>>>> cursor-ai-suite >>>>>' "$CR" || true)
if [[ "$block_count" -eq 1 ]]; then
  pass "C2e idempotent: exactly 1 block after 2 installs"
else
  fail "C2e idempotent: expected 1, got $block_count block start(s)"
fi

# C2f: uninstall removes block
(
  export HOME="$SANDBOX"
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
  source "$ADAPTER"
  agent_uninstall_global "$SUITE_DIR"
)
if ! grep -q '>>>>> cursor-ai-suite >>>>>' "$CR" 2>/dev/null; then
  pass "C2f uninstall removes AI Suite block from ~/.cursorrules"
else
  fail "C2f uninstall removes AI Suite block from ~/.cursorrules"
fi

# C2g: non-suite content preserved after uninstall
(
  export HOME="$SANDBOX"
  printf '\n# my custom rule\nalias ll=ls\n' >> "$CR"
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
  source "$ADAPTER"
  agent_install_global "$SUITE_DIR"
  agent_uninstall_global "$SUITE_DIR"
)
if grep -q 'my custom rule' "$CR" 2>/dev/null; then
  pass "C2g non-suite content preserved after install+uninstall"
else
  fail "C2g non-suite content preserved after install+uninstall"
fi

# C2h: project install does NOT touch ~/.cursorrules
PROJ="$SANDBOX/myproject"
mkdir -p "$PROJ"
BEFORE_CR_MTIME="$(stat -f '%m' "$CR" 2>/dev/null || stat -c '%Y' "$CR" 2>/dev/null || echo 0)"
(
  export HOME="$SANDBOX"
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
  source "$ADAPTER"
  agent_install_project "$SUITE_DIR" "$PROJ"
)
AFTER_CR_MTIME="$(stat -f '%m' "$CR" 2>/dev/null || stat -c '%Y' "$CR" 2>/dev/null || echo 0)"
if [[ "$BEFORE_CR_MTIME" == "$AFTER_CR_MTIME" ]]; then
  pass "C2h agent_install_project does NOT modify ~/.cursorrules"
else
  fail "C2h agent_install_project does NOT modify ~/.cursorrules"
fi


# C2j: without domain — only core+cursor skills (and all domains by default)
SANDBOX3=$(mktemp -d "${TMPDIR:-/tmp}/global-cr-contracts3.XXXXXX")
trap 'rm -rf "$SANDBOX3"' EXIT
(
  export HOME="$SANDBOX3"
  unset AI_SUITE_DOMAIN 2>/dev/null || true
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
  source "$ADAPTER"
  agent_install_global "$SUITE_DIR"
)
skill_count_no_domain=$(find "$SANDBOX3/.cursor/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
expected_no_domain=$(find \
  "$SUITE_DIR/layer3-registry/core" \
  "$SUITE_DIR/layer1-abstraction/agents/cursor/skills" \
  "$SUITE_DIR/layer4-evolutionary/merging" \
  "$SUITE_DIR/layer2-cognitive/meta-compiler" \
  "$SUITE_DIR/layer3-registry/domains"/*/skills \
  -maxdepth 1 -name '*.md' -type f 2>/dev/null | wc -l | tr -d ' ')
if [[ "$skill_count_no_domain" -eq "$expected_no_domain" ]]; then
  pass "C2j without domain: $skill_count_no_domain/$expected_no_domain skills (no domain)"
else
  fail "C2j without domain: expected $expected_no_domain, got $skill_count_no_domain"
fi

echo ""
TOTAL=$((PASS+FAIL))
printf '=== %d passed, %d FAILED out of %d ===\n' "$PASS" "$FAIL" "$TOTAL"
echo ""
[[ $FAIL -eq 0 ]]
