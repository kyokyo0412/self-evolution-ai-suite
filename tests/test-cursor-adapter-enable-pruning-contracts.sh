#!/usr/bin/env bash
# tests/test-cursor-adapter-enable-pruning-contracts.sh
# Validates that Cursor adapter enable cleans up obsolete skills, legacy rules, and stale templates/scripts
set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_DIR="$SUITE_ROOT/.ai-suite"
ADAPTER="$SUITE_DIR/layer1-abstraction/agents/cursor/adapter.sh"

PASS=0
FAIL=0

_red() { printf '\033[31m'; }
_grn() { printf '\033[32m'; }
_off() { printf '\033[0m'; }

pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== Phase 1.5 & Phase 2.3: Cursor Adapter Pruning Contract Tests ==="

# -----------------------------------------------------------------------------
# Test 1: Static Code Inspection Contract
# -----------------------------------------------------------------------------
echo ""
echo "--- Contract 1: Static Source Contracts ---"

if grep -q 'agent_uninstall_global.*suite_dir' "$ADAPTER" || grep -q 'agent_uninstall_global' "$ADAPTER"; then
  # Check if agent_install_global invokes agent_uninstall_global
  if awk '/agent_install_global\(\)/, /^}/' "$ADAPTER" | grep -q 'agent_uninstall_global'; then
    pass "C1a: agent_install_global invokes agent_uninstall_global"
  else
    fail "C1a: agent_install_global does NOT invoke agent_uninstall_global"
  fi
else
  fail "C1a: agent_uninstall_global missing from adapter"
fi

if awk '/agent_install_project\(\)/, /^}/' "$ADAPTER" | grep -q 'agent_uninstall_project'; then
  pass "C1b: agent_install_project invokes agent_uninstall_project"
else
  fail "C1b: agent_install_project does NOT invoke agent_uninstall_project"
fi

# -----------------------------------------------------------------------------
# Test 2: Functional Sandbox - Global Install Pruning
# -----------------------------------------------------------------------------
echo ""
echo "--- Contract 2: Functional Sandbox - Global Install Pruning ---"

SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/cursor-pruning-global.XXXXXX")
trap 'rm -rf "$SANDBOX"' EXIT

# Pre-populate sandbox with obsolete skills and legacy rules
mkdir -p "$SANDBOX/.cursor/skills/ai-expert"
echo "# Old AI Expert" > "$SANDBOX/.cursor/skills/ai-expert/SKILL.md"
mkdir -p "$SANDBOX/.cursor/skills/ai-review-fix-manual"
echo "# Old AI Review Fix Manual" > "$SANDBOX/.cursor/skills/ai-review-fix-manual/SKILL.md"
mkdir -p "$SANDBOX/.cursor/skills/prompt-enhancer"
echo "# Old Prompt Enhancer" > "$SANDBOX/.cursor/skills/prompt-enhancer/SKILL.md"

mkdir -p "$SANDBOX/.cursor/rules"
echo "# Legacy Agent Directives" > "$SANDBOX/.cursor/rules/agent-directives.md"
echo "# Legacy Production Safety" > "$SANDBOX/.cursor/rules/production-safety.md"

(
  export HOME="$SANDBOX"
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
  source "$ADAPTER"
  agent_install_global "$SUITE_DIR"
)

# Assertions
if [[ ! -d "$SANDBOX/.cursor/skills/ai-expert" ]]; then
  pass "C2a: Obsolete skill ai-expert pruned on global install"
else
  fail "C2a: Obsolete skill ai-expert was NOT pruned"
fi

if [[ ! -d "$SANDBOX/.cursor/skills/ai-review-fix-manual" ]]; then
  pass "C2b: Obsolete skill ai-review-fix-manual pruned on global install"
else
  fail "C2b: Obsolete skill ai-review-fix-manual was NOT pruned"
fi

if [[ ! -d "$SANDBOX/.cursor/skills/prompt-enhancer" ]]; then
  pass "C2c: Obsolete skill prompt-enhancer pruned on global install"
else
  fail "C2c: Obsolete skill prompt-enhancer was NOT pruned"
fi

if [[ ! -f "$SANDBOX/.cursor/rules/agent-directives.md" ]]; then
  pass "C2d: Legacy rule agent-directives.md pruned on global install"
else
  fail "C2d: Legacy rule agent-directives.md was NOT pruned"
fi

if [[ ! -f "$SANDBOX/.cursor/rules/production-safety.md" ]]; then
  pass "C2e: Legacy rule production-safety.md pruned on global install"
else
  fail "C2e: Legacy rule production-safety.md was NOT pruned"
fi

if [[ -f "$SANDBOX/.cursor/rules/cursor-suite-agent-directives.mdc" ]]; then
  pass "C2f: Modern rule cursor-suite-agent-directives.mdc successfully deployed"
else
  fail "C2f: Modern rule cursor-suite-agent-directives.mdc missing"
fi

if [[ -f "$SANDBOX/.cursor/skills/tdd-team/SKILL.md" ]]; then
  pass "C2g: Active core skill tdd-team deployed"
else
  fail "C2g: Active core skill tdd-team missing"
fi

# Dynamic skill count calculation
expected_skills_count=$(
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
  get_all_skill_files "$SUITE_DIR" "cursor" | wc -l | tr -d ' '
)
deployed_skills_count=$(find "$SANDBOX/.cursor/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

if [[ "$deployed_skills_count" -eq "$expected_skills_count" ]]; then
  pass "C2h: Dynamic skill count matches expected ($deployed_skills_count == $expected_skills_count)"
else
  fail "C2h: Dynamic skill count mismatch: deployed=$deployed_skills_count, expected=$expected_skills_count"
fi

# -----------------------------------------------------------------------------
# Test 3: Functional Sandbox - Project Install Pruning
# -----------------------------------------------------------------------------
echo ""
echo "--- Contract 3: Functional Sandbox - Project Install Pruning ---"

PROJ_SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/cursor-pruning-proj.XXXXXX")
trap 'rm -rf "$SANDBOX" "$PROJ_SANDBOX"' EXIT

mkdir -p "$PROJ_SANDBOX/.cursor/skills/obsolete-skill"
echo "# Obsolete" > "$PROJ_SANDBOX/.cursor/skills/obsolete-skill/SKILL.md"
mkdir -p "$PROJ_SANDBOX/.cursor/rules"
echo "# Legacy Rule" > "$PROJ_SANDBOX/.cursor/rules/legacy-rule.md"

(
  export HOME="$SANDBOX"
  # shellcheck source=/dev/null
  source "$SUITE_DIR/layer2-cognitive/memory/core.sh"
  source "$ADAPTER"
  agent_install_project "$SUITE_DIR" "$PROJ_SANDBOX"
)

if [[ ! -d "$PROJ_SANDBOX/.cursor/skills/obsolete-skill" ]]; then
  pass "C3a: Obsolete skill pruned on project install"
else
  fail "C3a: Obsolete skill was NOT pruned on project install"
fi

if [[ -f "$PROJ_SANDBOX/.cursor/skills/tdd-team/SKILL.md" ]]; then
  pass "C3b: Active skill tdd-team deployed in project"
else
  fail "C3b: Active skill tdd-team missing from project"
fi

echo ""
echo "=== Summary: $PASS passed, $FAIL failed ==="
[[ "$FAIL" -eq 0 ]] || exit 1
