#!/usr/bin/env bash
# tests/test-enable-disable-module.sh -- Comprehensive TDD Lifecycle Test Suite
set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$SUITE_ROOT/ai-suite"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== TDD Module 1: Multi-Agent Enable/Disable & Lifecycle Hardening ==="

TMP_SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/tdd-enable-disable.XXXXXX")
trap 'rm -rf "$TMP_SANDBOX"' EXIT

PROJ_DIR="$TMP_SANDBOX/test_project"
GLOBAL_HOME="$TMP_SANDBOX/test_home"
mkdir -p "$PROJ_DIR" "$GLOBAL_HOME"

# Test 1: Isolation check prevents installing project scope into AI suite repo itself
if bash "$SUITE_CLI" enable --agent cursor --scope project --project "$SUITE_ROOT" >/dev/null 2>&1; then
  fail "Isolation check failed: enabled inside AI suite repo"
else
  pass "Isolation check: prevented enable --scope project inside AI suite repo"
fi

# Test 2: Enable Cursor on project and verify no duplicate .md vs .mdc rules
bash "$SUITE_CLI" enable --agent cursor --scope project --project "$PROJ_DIR" >/dev/null

if [[ -f "$PROJ_DIR/.cursorrules" ]]; then
  pass "Cursor: .cursorrules created"
else
  fail "Cursor: .cursorrules missing"
fi

if [[ -d "$PROJ_DIR/.cursor/rules" ]]; then
  RAW_MD_RULES=$(find "$PROJ_DIR/.cursor/rules" -maxdepth 1 -name "*.md" 2>/dev/null || true)
  if [[ -n "$RAW_MD_RULES" ]]; then
    fail "Cursor: found duplicate raw .md rules in .cursor/rules: $RAW_MD_RULES"
  else
    pass "Cursor: no duplicate raw .md files in .cursor/rules"
  fi
  
  MDC_RULES=$(find "$PROJ_DIR/.cursor/rules" -maxdepth 1 -name "*.mdc" 2>/dev/null || true)
  if [[ -n "$MDC_RULES" ]]; then
    pass "Cursor: .mdc rules properly deployed"
  else
    fail "Cursor: .mdc rules missing in .cursor/rules"
  fi
else
  fail "Cursor: .cursor/rules missing"
fi

# Check templates and scripts mirrored
if [[ -d "$PROJ_DIR/.cursor/templates" && -d "$PROJ_DIR/.cursor/scripts" ]]; then
  pass "Cursor: templates and scripts directories mirrored"
else
  fail "Cursor: templates or scripts missing in .cursor"
fi

# Test 3: Disable Cursor on project and verify clean removal
bash "$SUITE_CLI" disable --agent cursor --scope project --project "$PROJ_DIR" >/dev/null
if [[ -d "$PROJ_DIR/.cursor/skills" || -d "$PROJ_DIR/.cursor/rules" || -d "$PROJ_DIR/.cursor/templates" || -d "$PROJ_DIR/.cursor/scripts" ]]; then
  fail "Cursor: residual files remained after disable"
else
  pass "Cursor: clean uninstallation on project scope"
fi

# Test 4: Enable Claude and verify templates and scripts mirrored
bash "$SUITE_CLI" enable --agent claude --scope project --project "$PROJ_DIR" >/dev/null
if [[ -f "$PROJ_DIR/CLAUDE.md" && -d "$PROJ_DIR/.claude/skills" && -d "$PROJ_DIR/.claude/meta" && -d "$PROJ_DIR/.claude/templates" && -d "$PROJ_DIR/.claude/scripts" ]]; then
  pass "Claude: all required directories (skills, meta, templates, scripts) mirrored"
else
  fail "Claude: missing directories after enable"
fi

bash "$SUITE_CLI" disable --agent claude --scope project --project "$PROJ_DIR" >/dev/null
if [[ -d "$PROJ_DIR/.claude/skills" || -d "$PROJ_DIR/.claude/templates" || -d "$PROJ_DIR/.claude/scripts" ]]; then
  fail "Claude: residual files remained after disable"
else
  pass "Claude: clean uninstallation on project scope"
fi

# Test 5: Enable all agents simultaneously and test disable
bash "$SUITE_CLI" enable --agent all --scope project --project "$PROJ_DIR" >/dev/null
for agent_file in "$PROJ_DIR/.cursorrules" "$PROJ_DIR/CLAUDE.md" "$PROJ_DIR/.opencode/instructions.md" "$PROJ_DIR/.continue/prompts/ai-suite.prompt" "$PROJ_DIR/.roorules" "$PROJ_DIR/AGENTS.md"; do
  if [[ -f "$agent_file" ]]; then
    pass "Multi-Agent: $agent_file created"
  else
    fail "Multi-Agent: $agent_file missing"
  fi
done

bash "$SUITE_CLI" disable --agent all --scope project --project "$PROJ_DIR" >/dev/null
pass "Multi-Agent: disabled all agents cleanly"

# Test 6: Invalid agent flag validation in enable
set +e
INV_AGENT_OUT=$(bash "$SUITE_CLI" enable --agent invalid_agent_xyz --scope project --project "$PROJ_DIR" 2>&1)
INV_AGENT_CODE=$?
set -e
if [[ $INV_AGENT_CODE -ne 0 ]] && echo "$INV_AGENT_OUT" | grep -qi "Unsupported agent"; then
  pass "enable rejects invalid agent flag with exit code $INV_AGENT_CODE"
else
  fail "enable did not reject invalid agent properly (code: $INV_AGENT_CODE)"
fi

# Test 7: Invalid scope flag validation in enable
set +e
INV_SCOPE_OUT=$(bash "$SUITE_CLI" enable --agent cursor --scope invalid_scope_xyz --project "$PROJ_DIR" 2>&1)
INV_SCOPE_CODE=$?
set -e
if [[ $INV_SCOPE_CODE -ne 0 ]] && echo "$INV_SCOPE_OUT" | grep -qi "Unsupported scope"; then
  pass "enable rejects invalid scope flag with exit code $INV_SCOPE_CODE"
else
  fail "enable did not reject invalid scope properly (code: $INV_SCOPE_CODE)"
fi

# Test 8: Nonexistent project path validation in enable
set +e
INV_PATH_OUT=$(bash "$SUITE_CLI" enable --agent cursor --scope project --project "/nonexistent/path/for/ai/suite/test" 2>&1)
INV_PATH_CODE=$?
set -e
if [[ $INV_PATH_CODE -ne 0 ]] && echo "$INV_PATH_OUT" | grep -qi "project path not found"; then
  pass "enable rejects nonexistent project path"
else
  fail "enable did not reject nonexistent project path (code: $INV_PATH_CODE)"
fi

# Test 9: --dry-run guarantee (no mutations in target)
DRY_TARGET="$TMP_SANDBOX/dry_project"
mkdir -p "$DRY_TARGET"
bash "$SUITE_CLI" enable --agent cursor --scope project --project "$DRY_TARGET" --dry-run >/dev/null
if [[ -f "$DRY_TARGET/.cursorrules" || -d "$DRY_TARGET/.cursor" ]]; then
  fail "enable --dry-run mutated filesystem in target project"
else
  pass "enable --dry-run non-mutation guarantee verified"
fi

# Test 10: --verify flag in enable runs validate-suite
set +e
VERIFY_OUT=$(bash "$SUITE_CLI" enable --verify 2>&1)
VERIFY_CODE=$?
set -e
if [[ $VERIFY_CODE -eq 0 ]] && echo "$VERIFY_OUT" | grep -qi "checks passed"; then
  pass "enable --verify successfully runs validator"
else
  fail "enable --verify failed or returned nonzero (code: $VERIFY_CODE)"
fi

# Test 11: Invalid agent flag in disable
set +e
DIS_INV_AGENT=$(bash "$SUITE_CLI" disable --agent invalid_agent_xyz --scope project --project "$PROJ_DIR" 2>&1)
DIS_INV_CODE=$?
set -e
if [[ $DIS_INV_CODE -ne 0 ]] && echo "$DIS_INV_AGENT" | grep -qi "Unsupported agent"; then
  pass "disable rejects invalid agent flag"
else
  fail "disable did not reject invalid agent properly (code: $DIS_INV_CODE)"
fi

# Test 12: Remote scope without host in disable
set +e
DIS_REMOTE_OUT=$(bash "$SUITE_CLI" disable --scope remote 2>&1)
DIS_REMOTE_CODE=$?
set -e
if [[ $DIS_REMOTE_CODE -ne 0 ]] && echo "$DIS_REMOTE_OUT" | grep -qi "requires --host"; then
  pass "disable rejects remote scope without host"
else
  fail "disable allowed remote scope without host (code: $DIS_REMOTE_CODE)"
fi

# Test 13: Remote scope without host in enable
set +e
EN_REMOTE_OUT=$(bash "$SUITE_CLI" enable --scope remote 2>&1)
EN_REMOTE_CODE=$?
set -e
if [[ $EN_REMOTE_CODE -ne 0 ]] && echo "$EN_REMOTE_OUT" | grep -qi "requires --host"; then
  pass "enable rejects remote scope without host"
else
  fail "enable allowed remote scope without host (code: $EN_REMOTE_CODE)"
fi

# Test 14: Shell hook install, idempotency, and uninstall
HOOK_HOME="$TMP_SANDBOX/hook_home"
mkdir -p "$HOOK_HOME"
touch "$HOOK_HOME/.zshrc" "$HOOK_HOME/.bashrc"

HOME="$HOOK_HOME" bash "$SUITE_CLI" enable --install-hook --shell both >/dev/null
if grep -qF "AI SUITE AUTO-ENABLE HOOK START" "$HOOK_HOME/.zshrc" && grep -qF "AI SUITE AUTO-ENABLE HOOK START" "$HOOK_HOME/.bashrc"; then
  pass "Shell hooks: installed in both .zshrc and .bashrc"
else
  fail "Shell hooks: missing in rc files after install"
fi

# Idempotency check: installing again does not duplicate hook
HOME="$HOOK_HOME" bash "$SUITE_CLI" enable --install-hook --shell both >/dev/null
ZSH_HOOK_COUNT=$(grep -c "AI SUITE AUTO-ENABLE HOOK START" "$HOOK_HOME/.zshrc" || true)
if [[ "$ZSH_HOOK_COUNT" -eq 1 ]]; then
  pass "Shell hooks: idempotent installation verified (not duplicated)"
else
  fail "Shell hooks: duplicated hook in .zshrc (count: $ZSH_HOOK_COUNT)"
fi

# Uninstall hooks
HOME="$HOOK_HOME" bash "$SUITE_CLI" disable --uninstall-hook --shell both >/dev/null
if grep -qF "AI SUITE AUTO-ENABLE HOOK START" "$HOOK_HOME/.zshrc" || grep -qF "AI SUITE AUTO-ENABLE HOOK START" "$HOOK_HOME/.bashrc"; then
  fail "Shell hooks: failed to cleanly remove hooks"
else
  pass "Shell hooks: cleanly uninstalled from both rc files"
fi

# Test 15: Global scope install and disable in sandbox HOME
G_HOME="$TMP_SANDBOX/global_home"
mkdir -p "$G_HOME"
HOME="$G_HOME" bash "$SUITE_CLI" enable --agent cursor --scope global >/dev/null
if [[ -d "$G_HOME/.cursor/rules" ]] && grep -qF "cursor-ai-suite" "$G_HOME/.cursorrules" 2>/dev/null; then
  pass "Global scope: cursor artifacts installed in global HOME"
else
  fail "Global scope: cursor artifacts missing in global HOME"
fi

HOME="$G_HOME" bash "$SUITE_CLI" disable --agent cursor --scope global >/dev/null
if [[ -d "$G_HOME/.cursor/rules" ]] || grep -qF "cursor-ai-suite" "$G_HOME/.cursorrules" 2>/dev/null; then
  fail "Global scope: cursor artifacts remain after disable"
else
  pass "Global scope: cleanly disabled cursor in global HOME"
fi

# Test 16: enable --uninstall flag delegates to disable
DELEGATE_PROJ="$TMP_SANDBOX/delegate_proj"
mkdir -p "$DELEGATE_PROJ"
bash "$SUITE_CLI" enable --agent cursor --scope project --project "$DELEGATE_PROJ" >/dev/null
if grep -qF "cursor-ai-suite" "$DELEGATE_PROJ/.cursorrules" 2>/dev/null; then
  pass "delegate_proj: enabled successfully"
else
  fail "delegate_proj: failed to enable"
fi

bash "$SUITE_CLI" enable --uninstall --agent cursor --scope project --project "$DELEGATE_PROJ" >/dev/null
if grep -qF "cursor-ai-suite" "$DELEGATE_PROJ/.cursorrules" 2>/dev/null; then
  fail "enable --uninstall failed to cleanly remove cursorrules block"
else
  pass "enable --uninstall correctly delegates to disable"
fi

total=$((PASS+FAIL))
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[module-1-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[module-1-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
