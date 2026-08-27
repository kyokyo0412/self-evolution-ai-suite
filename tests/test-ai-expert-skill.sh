#!/bin/bash
set -e

CORE_SKILL=".ai-suite/layer2-cognitive/meta-compiler/prompt-compiler.md"
if [ ! -f "$CORE_SKILL" ]; then
  CORE_SKILL=".ai-suite/layer2-cognitive/meta-compiler/ai-expert.md"
fi

# Check if file exists
if [ ! -f "$CORE_SKILL" ]; then
  echo "Error: $CORE_SKILL does not exist"
  exit 1
fi

# Check frontmatter
if ! grep -qE "name: (ai-expert|prompt-compiler)" "$CORE_SKILL"; then
  echo "Error: Missing name in $CORE_SKILL"
  exit 1
fi

if ! grep -q "AI Expert" "$CORE_SKILL"; then
  echo "Error: Missing 'AI Expert' in $CORE_SKILL"
  exit 1
fi

if ! grep -q "Prompt Architect" "$CORE_SKILL"; then
  echo "Error: Missing 'Prompt Architect' in $CORE_SKILL"
  exit 1
fi

if ! grep -q "review ai-suite enhancements" "$CORE_SKILL" && ! grep -q "review the AI-suite when it is enhanced" "$CORE_SKILL"; then
  echo "Error: Missing enhancement review capability in $CORE_SKILL"
  exit 1
fi

echo "AI-Expert core skill tests passed."
exit 0
