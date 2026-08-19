#!/bin/bash
set -e

FEATURE_FILE="tests/question-doc.feature"

echo "Validating requirements in $FEATURE_FILE..."

grep -qi "answer to the question" "$FEATURE_FILE" || { echo "Missing: answer to the question requirement"; exit 1; }
grep -qi "codebase discovery" "$FEATURE_FILE" || { echo "Missing: codebase discovery requirement"; exit 1; }
grep -qi "trace chain" "$FEATURE_FILE" || { echo "Missing: trace chain requirement"; exit 1; }
grep -qi "aigen_doc/" "$FEATURE_FILE" || { echo "Missing: aigen_doc output constraint"; exit 1; }

echo "Requirement validation PASSED."
exit 0
