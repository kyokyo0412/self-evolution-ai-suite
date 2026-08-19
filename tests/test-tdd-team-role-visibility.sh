#!/bin/bash

# Tests to ensure the tdd-team skill explicitly mandates role visibility
# before executing any file-edit or shell tools.

set -e

SKILL_FILE=".ai-suite/layer3-registry/core/tdd-team.md"

if [ ! -f "$SKILL_FILE" ]; then
    echo "FAIL: $SKILL_FILE not found!"
    exit 1
fi

if ! grep -q "Do not skip Role Visibility" "$SKILL_FILE"; then
    echo "FAIL: $SKILL_FILE does not contain 'Do not skip Role Visibility' constraint."
    exit 1
fi

if ! grep -q "Do not execute any file-edit or shell tools for a phase until you have explicitly output the Role Visibility" "$SKILL_FILE"; then
    echo "FAIL: $SKILL_FILE does not explicitly mandate outputting role visibility before tools."
    exit 1
fi

echo "PASS: $SKILL_FILE mandates role visibility before executing tools."
exit 0
