#!/bin/bash
set -euo pipefail

FAIL_COUNT=0

check_skill_file() {
    local file="$1"
    if ! grep -qi "Negative Constraints" "$file"; then
        echo "FAIL (Skill): $file is missing the 'Negative Constraints' boundary section."
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

check_directive_file() {
    local file="$1"
    if ! grep -qiE "Constraints|Must NOT|Strict" "$file"; then
        echo "FAIL (Directive): $file is missing strict constraints or boundaries."
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

echo "Validating 1E-Class Security on AI suite prompts..."
for file in $(find .ai-suite/layer3-registry/core .ai-suite/layer4-evolutionary/merging .ai-suite/layer1-abstraction/agents/cursor/skills -type f -name "*.md"); do
    check_skill_file "$file"
done

for file in $(find .ai-suite/layer3-registry/directives -type f -name "*.md"); do
    check_directive_file "$file"
done

if [[ "$FAIL_COUNT" -gt 0 ]]; then
    echo "Total prompt failures: $FAIL_COUNT"
    exit 1
fi

echo "PASS: All AI suite prompts adhere to base 1E-Class Security boundaries."
exit 0
