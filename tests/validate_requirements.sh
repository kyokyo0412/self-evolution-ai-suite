#!/bin/bash
set -e

FEATURE_FILE="tests/feature-doc-enhancement.feature"

echo "Validating requirements in $FEATURE_FILE..."

grep -qi "answer to the question" "$FEATURE_FILE" || { echo "Missing: answer to the question requirement"; exit 1; }
grep -qi "architecture and design" "$FEATURE_FILE" || { echo "Missing: architecture mapping requirement"; exit 1; }
grep -qi "modules and codes" "$FEATURE_FILE" || { echo "Missing: code mapping requirement"; exit 1; }
grep -qi "extra information" "$FEATURE_FILE" || { echo "Missing: extra information requirement"; exit 1; }
grep -qi "aigen_doc/" "$FEATURE_FILE" || { echo "Missing: aigen_doc output constraint"; exit 1; }
grep -qi "not stop to ask" "$FEATURE_FILE" || { echo "Missing: no interruption constraint"; exit 1; }

echo "Requirement validation PASSED."
exit 0
