#!/usr/bin/env bash
set -euo pipefail

# test-cursor-only-interactive-workflow-isolation.sh
# Validates that:
# 1. Universal directives (agent-directives.md) do NOT contain AskQuestion or interactive workflow instructions.
# 2. Non-cursor agent configurations (codex, claude, roo-code, continue, opencode) contain ZERO references to interactive workflow or AskQuestion.
# 3. Cursor agent configuration retains full interactive workflow rule definitions and AskQuestion state machine.
# 4. loop-work skill explicitly gates AskQuestion and interactive workflow wrap-up to Cursor Agent.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

DIRECTIVES_FILE=".ai-suite/layer3-registry/directives/agent-directives.md"
CURSOR_RULE=".ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md"
LOOP_WORK_SKILL=".ai-suite/layer3-registry/core/loop-work.md"
CORE_SH=".ai-suite/layer2-cognitive/memory/core.sh"

echo "=== Running Multi-Agent Interactive Workflow Isolation Tests ==="

FAILURES=0

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  local desc="$3"

  if grep -qiE "$pattern" "$file" 2>/dev/null; then
    echo "  [FAIL] $file: Found unexpected pattern for $desc (pattern: '$pattern')"
    grep -n -iE "$pattern" "$file" | head -5
    FAILURES=$((FAILURES + 1))
  else
    echo "  [PASS] $file: Verified absence of $desc"
  fi
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  local desc="$3"

  if ! grep -qiE "$pattern" "$file" 2>/dev/null; then
    echo "  [FAIL] $file: Missing $desc (pattern: '$pattern')"
    FAILURES=$((FAILURES + 1))
  else
    echo "  [PASS] $file: $desc"
  fi
}

echo "1. Checking Universal Directives Purity ($DIRECTIVES_FILE)..."
assert_not_contains "$DIRECTIVES_FILE" "AskQuestion" "AskQuestion tool in universal directives"
assert_not_contains "$DIRECTIVES_FILE" "interactive.*workflow" "Interactive workflow in universal directives"
assert_not_contains "$DIRECTIVES_FILE" "Continuous Interactive Workflow Persistence" "Section 15 interactive workflow in universal directives"

echo "2. Checking Cursor Rule Completeness ($CURSOR_RULE)..."
assert_contains "$CURSOR_RULE" "strictly and ONLY for the Cursor Agent" "Cursor agent exclusivity declaration"
assert_contains "$CURSOR_RULE" "State 0.*INITIALIZATION" "State 0 initialization"
assert_contains "$CURSOR_RULE" "State 1.*MAIN TASK" "State 1 main task"
assert_contains "$CURSOR_RULE" "State 2.*WRAP-UP" "State 2 wrap-up"
assert_contains "$CURSOR_RULE" "State 3.*THE FOLLOW-UP LOOP" "State 3 follow-up loop"
assert_contains "$CURSOR_RULE" "AskQuestion" "AskQuestion tool in Cursor interactive workflow"
assert_contains "$CURSOR_RULE" "Must not cost any extra Cursor included request" "Zero-cost refinement guarantee"

echo "3. Checking Loop-Work Skill Isolation ($LOOP_WORK_SKILL)..."
assert_contains "$LOOP_WORK_SKILL" "Cursor Agent" "Cursor Agent qualification in loop-work"

echo "4. Checking Generated Configurations for Non-Cursor Agents..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

source "$CORE_SH"

for agent in codex claude roo-code continue opencode; do
  echo "  -> Testing config generation for agent: $agent"
  OUTPUT=$(generate_markdown_block "$ROOT_DIR/.ai-suite" "$TMP_DIR" "$agent" "<!-- start -->" "<!-- end -->")

  if echo "$OUTPUT" | grep -qiE "(interactive-workflow|AskQuestion)"; then
    echo "    [FAIL] generate_markdown_block for $agent contains interactive-workflow or AskQuestion!"
    echo "$OUTPUT" | grep -n -iE "(interactive-workflow|AskQuestion)" | head -5
    FAILURES=$((FAILURES + 1))
  else
    echo "    [PASS] generate_markdown_block for $agent is clean of interactive workflow and AskQuestion"
  fi
done

echo "5. Testing Full Enable Lifecycle for Non-Cursor Agents..."
ENABLE_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR" "$ENABLE_DIR"' EXIT

bash ai-suite enable --agent codex --scope project --project "$ENABLE_DIR" >/dev/null 2>&1
bash ai-suite enable --agent claude --scope project --project "$ENABLE_DIR" >/dev/null 2>&1
bash ai-suite enable --agent roo-code --scope project --project "$ENABLE_DIR" >/dev/null 2>&1
bash ai-suite enable --agent continue --scope project --project "$ENABLE_DIR" >/dev/null 2>&1
bash ai-suite enable --agent opencode --scope project --project "$ENABLE_DIR" >/dev/null 2>&1

for cfg in "$ENABLE_DIR/AGENTS.md" "$ENABLE_DIR/CLAUDE.md" "$ENABLE_DIR/.roorules" "$ENABLE_DIR/.continue/prompts/ai-suite.prompt" "$ENABLE_DIR/.opencode/instructions.md"; do
  if [[ -f "$cfg" ]]; then
    assert_not_contains "$cfg" "(interactive-workflow|AskQuestion)" "Interactive workflow / AskQuestion in $(basename "$cfg")"
  fi
done

# Also verify mirrored directives in .codex/directives
if [[ -d "$ENABLE_DIR/.codex/directives" ]]; then
  for d in "$ENABLE_DIR/.codex/directives"/*; do
    [[ -f "$d" ]] || continue
    assert_not_contains "$d" "(AskQuestion|interactive.*workflow)" "Interactive workflow / AskQuestion in mirrored directive $(basename "$d")"
  done
fi

echo "=================================================================="
if [ "$FAILURES" -gt 0 ]; then
  echo "TEST SUITE FAILED: $FAILURES failure(s) detected."
  exit 1
fi

echo "TEST SUITE PASSED: Interactive workflow is strictly isolated to Cursor Agent."
exit 0
