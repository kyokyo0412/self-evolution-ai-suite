#!/usr/bin/env bash
set -euo pipefail

TARGET_FILE=".ai-suite/layer3-registry/core/tdd-team.md"

echo "Running acceptance test for tdd-team documentation update rule..."

if ! grep -q "updates the primary project documentation" "$TARGET_FILE"; then
    echo "FAILED: tdd-team.md does not contain the rule to update primary project documentation."
    exit 1
fi

if ! grep -q "README.md" "$TARGET_FILE"; then
    echo "FAILED: tdd-team.md does not explicitly mention README.md in the update rule."
    exit 1
fi

echo "PASSED: tdd-team.md correctly instructs the Technical Writer to update project documentation (e.g. README.md)."
exit 0
