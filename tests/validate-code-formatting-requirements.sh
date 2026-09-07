#!/usr/bin/env bash
set -euo pipefail

# validate-code-formatting-requirements.sh
# Validates the Gherkin specification and requirement completeness for Code Formatting & Style directives.

FEATURE_FILE="tests/code-formatting-directives.feature"

echo "=== [SDET Gate] Validating Code Formatting Requirements ==="

if [[ ! -f "$FEATURE_FILE" ]]; then
    echo "FAIL: Feature file missing: $FEATURE_FILE"
    exit 1
fi

echo "Checking Gherkin syntax and required scenarios..."

# Validate presence of core scenarios
grep -qi "Scenario: Go code adheres to gofmt standard" "$FEATURE_FILE" || { echo "FAIL: Missing Go gofmt scenario"; exit 1; }
grep -qi "Scenario: C code adheres to clang-format standard" "$FEATURE_FILE" || { echo "FAIL: Missing C clang-format scenario"; exit 1; }
grep -qi "Scenario: Prevention of trivial empty lines" "$FEATURE_FILE" || { echo "FAIL: Missing trivial empty lines scenario"; exit 1; }
grep -qi "Scenario: Selective formatting scope for changed lines only" "$FEATURE_FILE" || { echo "FAIL: Missing selective formatting scenario"; exit 1; }
grep -qi "Scenario: Deployment of code formatting directives" "$FEATURE_FILE" || { echo "FAIL: Missing deployment scenario"; exit 1; }

# Validate key keywords
grep -qi "gofmt" "$FEATURE_FILE" || { echo "FAIL: Missing gofmt requirement"; exit 1; }
grep -qi "clang-format" "$FEATURE_FILE" || { echo "FAIL: Missing clang-format requirement"; exit 1; }
grep -qi "spaces or tabs" "$FEATURE_FILE" || { echo "FAIL: Missing whitespace on empty lines requirement"; exit 1; }
grep -qi "unchanged code" "$FEATURE_FILE" || { echo "FAIL: Missing unchanged code protection requirement"; exit 1; }

echo "PASS: Requirements and Gherkin feature specification verified successfully."
exit 0
