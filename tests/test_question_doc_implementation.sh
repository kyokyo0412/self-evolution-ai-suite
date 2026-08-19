#!/bin/bash
set -e

TARGET_FILE="/Users/dc005518/gitsource/dc005518_cursor_evolution/.ai-suite/layer3-registry/core/question-doc.md"

echo "Validating implementation in $TARGET_FILE..."

if [ ! -f "$TARGET_FILE" ]; then
  echo "RED: Target file $TARGET_FILE does not exist."
  exit 1
fi

grep -qi "answer the user's questions" "$TARGET_FILE" || { echo "RED: Skill does not specify answering questions."; exit 1; }
grep -qi "Code Trace & Execution Flow" "$TARGET_FILE" || { echo "RED: Missing Code Trace section."; exit 1; }
grep -qi "Detailed Behaviors" "$TARGET_FILE" || { echo "RED: Missing Detailed Behaviors section."; exit 1; }
grep -qi "aigen_doc/" "$TARGET_FILE" || { echo "RED: Missing aigen_doc output directory rule."; exit 1; }

echo "GREEN: Implementation validation PASSED."
exit 0
