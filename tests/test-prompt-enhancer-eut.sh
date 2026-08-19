#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_DIR="$(cd "$SCRIPT_DIR/../.ai-suite" && pwd)"
SKILL_FILE="$SUITE_DIR/layer2-cognitive/meta-compiler/prompt-enhancer.md"

echo "Running prompt-enhancer EUT tests..."

if [[ ! -f "$SKILL_FILE" ]]; then
  echo "FAIL: Skill file not found: $SKILL_FILE"
  exit 1
fi

echo "Validating skill with validate-suite.sh..."
# Check that validate-suite.sh passes. We run it over the whole suite or specifically.
# validate-suite.sh normally checks all skills. We will just check if validate-suite exits 0
if ! bash "$SUITE_DIR/layer4-evolutionary/validation/validate-suite.sh"; then
  echo "FAIL: validate-suite.sh rejected the skill file."
  exit 1
fi

echo "PASS: validate-suite.sh successfully validated the skill."
exit 0
