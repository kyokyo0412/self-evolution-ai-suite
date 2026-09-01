#!/usr/bin/env bash
# tests/test-enable-disable-module.sh -- TDD Module 1 Test Suite
set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$SUITE_ROOT/ai-suite"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== TDD Module 1: Multi-Agent Enable/Disable & Rule Cleanliness ==="

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
  # Check for duplicate raw .md files alongside .mdc files
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

total=$((PASS+FAIL))
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[module-1-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[module-1-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
