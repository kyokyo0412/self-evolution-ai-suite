#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-frontend-architecture-contracts.sh
# Validates frontend & mobile architectural requirements in tdd-team skill

check_frontend_arch_contracts() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating Frontend & Mobile Architecture contracts in: $file"

  # 1. Dumb vs Smart Component Separation
  if ! grep -qi "dumb" "$file" || ! grep -qi "pure presentation" "$file"; then
    echo "  FAIL: Dumb presentation component mandate missing in $file"
    return 1
  fi

  # 2. Custom Hooks & State Management Isolation
  if ! grep -qi "custom hook" "$file" || ! grep -qi "state management" "$file"; then
    echo "  FAIL: Custom hooks and state management isolation missing in $file"
    return 1
  fi

  # 3. Responsive & Mobile Architecture
  if ! grep -qi "responsive" "$file" || ! grep -qi "mobile" "$file"; then
    echo "  FAIL: Responsive and mobile architecture missing in $file"
    return 1
  fi

  # 4. Modern Tech Stack Guidance
  if ! grep -qi "tech stack" "$file" || ! grep -qi "framework" "$file"; then
    echo "  FAIL: Modern tech stack guidance missing in $file"
    return 1
  fi

  echo "  PASS: Frontend & Mobile Architecture contracts verified for $file"
  return 0
}

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

PASS_COUNT=0
FAIL_COUNT=0

if check_frontend_arch_contracts "$TARGET_SOURCE"; then
  PASS_COUNT=$((PASS_COUNT + 1))
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if [ -f "$TARGET_CURSOR" ]; then
  if check_frontend_arch_contracts "$TARGET_CURSOR"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ -f "$TARGET_CODEX" ]; then
  if check_frontend_arch_contracts "$TARGET_CODEX"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed Frontend Architecture contract verification."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT checked files passed Frontend Architecture contract verification."
exit 0
