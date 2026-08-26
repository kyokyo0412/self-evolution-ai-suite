#!/usr/bin/env bash
# test-all-agents-eut.sh - Comprehensive EUT testing all 6 agents (cursor, claude, opencode, continue, roo-code, codex)
set -euo pipefail

PASS=0
FAIL=0

pass() {
  printf '  [PASS] %s\n' "$1"
  PASS=$((PASS + 1))
}

fail() {
  printf '  [FAIL] %s\n' "$1" >&2
  FAIL=$((FAIL + 1))
}

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$PROJECT_ROOT/ai-suite"

echo "=== Comprehensive Multi-Agent E2E QA Gate ==="

ALL_AGENTS=("cursor" "claude" "opencode" "continue" "roo-code" "codex")

for agent in "${ALL_AGENTS[@]}"; do
  echo ""
  echo "--- Testing Agent: $agent ---"
  
  SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/eut-agent-${agent}.XXXXXX")
  trap 'rm -rf "$SANDBOX"' EXIT
  
  PROJ_DIR="$SANDBOX/proj"
  mkdir -p "$PROJ_DIR"
  
  # 1. Project Scope Enable
  (
    export HOME="$SANDBOX/home"
    mkdir -p "$HOME"
    bash "$SUITE_CLI" enable --agent "$agent" --scope project --project "$PROJ_DIR" >/dev/null 2>&1
  )
  
  case "$agent" in
    cursor)
      INSTRUCTION_FILE="$PROJ_DIR/.cursorrules"
      SKILLS_DIR="$PROJ_DIR/.cursor/skills"
      META_DIR="$PROJ_DIR/.cursor/meta"
      ;;
    claude)
      INSTRUCTION_FILE="$PROJ_DIR/CLAUDE.md"
      SKILLS_DIR="$PROJ_DIR/.claude/skills"
      META_DIR="$PROJ_DIR/.claude/meta"
      ;;
    opencode)
      INSTRUCTION_FILE="$PROJ_DIR/.opencode/instructions.md"
      SKILLS_DIR="$PROJ_DIR/.opencode/skills"
      META_DIR="$PROJ_DIR/.opencode/meta"
      ;;
    continue)
      INSTRUCTION_FILE="$PROJ_DIR/.continue/prompts/ai-suite.prompt"
      SKILLS_DIR="$PROJ_DIR/.continue/skills"
      META_DIR="$PROJ_DIR/.continue/meta"
      ;;
    roo-code)
      INSTRUCTION_FILE="$PROJ_DIR/.roorules"
      SKILLS_DIR="$PROJ_DIR/.roo/skills"
      META_DIR="$PROJ_DIR/.roo/meta"
      ;;
    codex)
      INSTRUCTION_FILE="$PROJ_DIR/AGENTS.md"
      SKILLS_DIR="$PROJ_DIR/.codex/skills"
      META_DIR="$PROJ_DIR/.codex/meta"
      ;;
  esac
  
  if [[ -f "$INSTRUCTION_FILE" ]]; then
    pass "$agent: instruction file created ($INSTRUCTION_FILE)"
  else
    fail "$agent: instruction file missing ($INSTRUCTION_FILE)"
  fi
  
  if [[ -d "$SKILLS_DIR" ]]; then
    pass "$agent: skills directory populated ($SKILLS_DIR)"
  else
    fail "$agent: skills directory missing ($SKILLS_DIR)"
  fi
  
  if [[ -d "$META_DIR" ]]; then
    pass "$agent: meta directory populated ($META_DIR)"
  else
    fail "$agent: meta directory missing ($META_DIR)"
  fi
  
  # Verify directives and safety rules exist in instruction file (or .cursor/rules for cursor)
  if [[ "$agent" == "cursor" ]]; then
    if [[ -f "$PROJ_DIR/.cursor/rules/cursor-suite-production-safety.mdc" ]] && [[ -f "$PROJ_DIR/.cursor/rules/cursor-suite-agent-directives.mdc" ]]; then
      pass "$agent: .cursor/rules deployed with safety and directives"
    else
      fail "$agent: .cursor/rules missing safety or directives"
    fi
  else
    if grep -q "Agent General Directives" "$INSTRUCTION_FILE" && grep -q "Production Safety Guardrails" "$INSTRUCTION_FILE"; then
      pass "$agent: instruction file contains embedded directives and safety rules"
    else
      fail "$agent: instruction file missing embedded directives or safety rules"
    fi
  fi
  
  # 2. Disable in Project Scope
  (
    export HOME="$SANDBOX/home"
    bash "$SUITE_CLI" disable --agent "$agent" --scope project --project "$PROJ_DIR" >/dev/null 2>&1
  )
  
  if [[ -d "$SKILLS_DIR" ]]; then
    fail "$agent: skills directory not removed after disable"
  else
    pass "$agent: skills directory removed after disable"
  fi
  
  if [[ "$agent" == "cursor" ]]; then
    if grep -q ">>>>> cursor-ai-suite >>>>>" "$INSTRUCTION_FILE" 2>/dev/null; then
      fail "$agent: .cursorrules block not removed after disable"
    else
      pass "$agent: .cursorrules block removed after disable"
    fi
  else
    if grep -q "<!-- ai-suite:start -->" "$INSTRUCTION_FILE" 2>/dev/null; then
      fail "$agent: ai-suite block not removed after disable"
    else
      pass "$agent: ai-suite block removed after disable"
    fi
  fi
  
  # 3. Global Scope Enable & Disable
  (
    export HOME="$SANDBOX/home"
    mkdir -p "$HOME"
    bash "$SUITE_CLI" enable --agent "$agent" --scope global >/dev/null 2>&1
  )
  
  case "$agent" in
    cursor)
      GLOBAL_INST="$SANDBOX/home/.cursorrules"
      GLOBAL_SKILLS="$SANDBOX/home/.cursor/skills"
      ;;
    claude)
      GLOBAL_INST="$SANDBOX/home/.claude/CLAUDE.md"
      GLOBAL_SKILLS="$SANDBOX/home/.claude/skills"
      ;;
    opencode)
      GLOBAL_INST="$SANDBOX/home/.config/opencode/instructions.md"
      GLOBAL_SKILLS="$SANDBOX/home/.config/opencode/skills"
      ;;
    continue)
      GLOBAL_INST="$SANDBOX/home/.continue/prompts/ai-suite.prompt"
      GLOBAL_SKILLS="$SANDBOX/home/.continue/skills"
      ;;
    roo-code)
      GLOBAL_INST="$SANDBOX/home/.roo/.roorules"
      GLOBAL_SKILLS="$SANDBOX/home/.roo/skills"
      ;;
    codex)
      GLOBAL_INST="$SANDBOX/home/.codex/AGENTS.md"
      GLOBAL_SKILLS="$SANDBOX/home/.codex/skills"
      ;;
  esac
  
  if [[ -f "$GLOBAL_INST" ]]; then
    pass "$agent: global instruction file created ($GLOBAL_INST)"
  else
    fail "$agent: global instruction file missing ($GLOBAL_INST)"
  fi
  
  if [[ -d "$GLOBAL_SKILLS" ]]; then
    pass "$agent: global skills directory populated ($GLOBAL_SKILLS)"
  else
    fail "$agent: global skills directory missing ($GLOBAL_SKILLS)"
  fi
  
  (
    export HOME="$SANDBOX/home"
    bash "$SUITE_CLI" disable --agent "$agent" --scope global >/dev/null 2>&1
  )
  
  if [[ -d "$GLOBAL_SKILLS" ]]; then
    fail "$agent: global skills directory not removed after disable"
  else
    pass "$agent: global skills directory removed after disable"
  fi
  
  rm -rf "$SANDBOX"
done

echo ""
echo "=== Summary: $PASS passed, $FAIL failed ==="
if [[ "$FAIL" -gt 0 ]]; then
  exit 1
fi
exit 0
