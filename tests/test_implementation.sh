#!/bin/bash
set -e

TARGET_FILE=".ai-suite/layer3-registry/core/feature-doc.md"

echo "Validating implementation in $TARGET_FILE..."

if [ ! -f "$TARGET_FILE" ]; then
  echo "Error: Target file $TARGET_FILE does not exist."
  exit 1
fi

# Check for the main purpose of answering questions
grep -qi "answer the user's questions" "$TARGET_FILE" || { echo "RED: Skill does not specify answering questions."; exit 1; }

# Check for required document sections
grep -qi "Executive Summary & Answer" "$TARGET_FILE" || { echo "RED: Missing Executive Summary & Answer section."; exit 1; }
grep -qi "Architecture & Design Mapping" "$TARGET_FILE" || { echo "RED: Missing Architecture & Design Mapping section."; exit 1; }
grep -qi "Module & Code Mapping" "$TARGET_FILE" || { echo "RED: Missing Module & Code Mapping section."; exit 1; }
grep -qi "Extra Beneficial Information" "$TARGET_FILE" || { echo "RED: Missing Extra Beneficial Information section."; exit 1; }

# Check for constraints
grep -qi "Output doc to aigen_doc/" "$TARGET_FILE" || { echo "RED: Missing aigen_doc output directory rule."; exit 1; }
grep -qi "exhausted" "$TARGET_FILE" || { echo "RED: Missing exhaustive write rule."; exit 1; }
grep -qi "not stop to ask users input" "$TARGET_FILE" || { echo "RED: Missing 'do not stop to ask' negative constraint."; exit 1; }

echo "GREEN: Implementation validation PASSED."
exit 0
