#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-ai-workflow-patterns-contracts.sh
# Validates AI-augmented workflow patterns in tdd-team skill

check_ai_workflow_patterns() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating AI-Augmented Workflow Patterns in: $file"

  # 1. Streaming & Token Latency Handling
  if ! grep -qi "streaming" "$file"; then
    echo "  FAIL: AI streaming criteria missing in $file"
    return 1
  fi

  # 2. Optimistic UI Updates
  if ! grep -qi "optimistic" "$file"; then
    echo "  FAIL: Optimistic UI criteria missing in $file"
    return 1
  fi

  # 3. Generative Skeletons & Fallback Recovery
  if ! grep -qi "skeleton\|fallback" "$file"; then
    echo "  FAIL: Generative skeleton / fallback criteria missing in $file"
    return 1
  fi

  # 4. Human-in-the-Loop Validation
  if ! grep -qi "human-in-the-loop\|validation checkpoint" "$file"; then
    echo "  FAIL: Human-in-the-loop validation checkpoints missing in $file"
    return 1
  fi

  echo "  PASS: AI-Augmented Workflow Patterns verified for $file"
  return 0
}

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

PASS_COUNT=0
FAIL_COUNT=0

if check_ai_workflow_patterns "$TARGET_SOURCE"; then
  PASS_COUNT=$((PASS_COUNT + 1))
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if [ -f "$TARGET_CURSOR" ]; then
  if check_ai_workflow_patterns "$TARGET_CURSOR"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ -f "$TARGET_CODEX" ]; then
  if check_ai_workflow_patterns "$TARGET_CODEX"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed AI Workflow Patterns verification."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT checked files passed AI Workflow Patterns verification."
exit 0
