#!/bin/bash
set -euo pipefail

FAIL_COUNT=0

check_file() {
    local file="$1"
    # 1. Check for set -eu or set -e, -u
    if ! grep -qE "set.*-.*e" "$file" || ! grep -qE "set.*-.*u" "$file"; then
        if ! grep -q "set -eu" "$file"; then
            echo "FAIL: $file is missing strict 'set -e' and 'set -u' constraints."
            ((FAIL_COUNT++))
        fi
    fi

    # 2. Check for unbounded loops, avoiding matching this script's own regex string
    if grep -vE "grep.*while" "$file" | grep -qE "while[[:space:]]+true|while[[:space:]]+\[[[:space:]]+1[[:space:]]+\]|while[[:space:]]+:"; then
        echo "FAIL: $file contains an unbounded while loop which violates Deterministic Execution."
        ((FAIL_COUNT++))
    fi
}

echo "Validating 1E-Class Security across AI suite..."
for file in $(find .ai-suite -type f -name "*.sh"); do
    check_file "$file"
done

if [[ "$FAIL_COUNT" -gt 0 ]]; then
    echo "Total failures: $FAIL_COUNT"
    exit 1
fi

echo "PASS: All scripts adhere to base 1E-Class Security constraints."
exit 0
