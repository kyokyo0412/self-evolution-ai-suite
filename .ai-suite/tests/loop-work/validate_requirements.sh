#!/bin/bash
set -euo pipefail
set -e

SKILL_FILE=".ai-suite/layer3-registry/core/loop-work.md"
CURSOR_SKILL_FILE=".ai-suite/layer1-abstraction/agents/cursor/skills/loop.md"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Error: $SKILL_FILE does not exist"
  exit 1
fi

REQUIRED_PHRASES=(
  "never-give-up spirit"
  "isolation principle"
  "self-evolution"
  "LLM thinking"\|"LLM reasoning"
  "validate the result"
  "design improvements"
)

for phrase in "${REQUIRED_PHRASES[@]}"; do
  if ! grep -qiE "$phrase" "$SKILL_FILE"; then
    echo "Error: Missing required phrase '$phrase' in $SKILL_FILE"
    exit 1
  fi
done

if [ ! -f "$CURSOR_SKILL_FILE" ]; then
  echo "Error: Cursor skill file $CURSOR_SKILL_FILE was not restored"
  exit 1
fi

if ! grep -q "^name: loop" "$CURSOR_SKILL_FILE"; then
  echo "Error: Cursor skill file should have 'name: loop'"
  exit 1
fi

echo "Requirement validation passed: All constraints are documented."
exit 0
