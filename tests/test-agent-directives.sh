#!/usr/bin/env bash
set -e

echo "Running agent directives validation test..."

DIRECTIVES_FILE=".ai-suite/layer3-registry/directives/agent-directives.md"
MDC_FILE=".cursor/rules/cursor-suite-agent-directives.mdc"

# Step 1: Check source file exists
if [[ ! -f "$DIRECTIVES_FILE" ]]; then
    echo "FAIL: Source directives file missing: $DIRECTIVES_FILE"
    exit 1
fi

# Step 2: Check required keywords in source file
if ! grep -i "git commit" "$DIRECTIVES_FILE" >/dev/null; then
    echo "FAIL: Directives file must mention leaving git commit to the user"
    exit 1
fi

if ! grep -i "summary" "$DIRECTIVES_FILE" >/dev/null; then
    echo "FAIL: Directives file must mention providing a summary"
    exit 1
fi

if ! grep -i "normal report" "$DIRECTIVES_FILE" >/dev/null; then
    echo "FAIL: Directives file must mention that summary follows normal report"
    exit 1
fi

if ! grep -i "multiple skills" "$DIRECTIVES_FILE" >/dev/null; then
    echo "FAIL: Directives file must mention multiple skills execution"
    exit 1
fi

if ! grep -i "verification" "$DIRECTIVES_FILE" >/dev/null; then
    echo "FAIL: Directives file must mention backing tasks by actual verification"
    exit 1
fi

# Step 2.1: Check Negative Constraints
if ! grep -i "Negative Constraints (Must NOT)" "$DIRECTIVES_FILE" >/dev/null; then
    echo "FAIL: Directives file must contain 'Negative Constraints (Must NOT)' section"
    exit 1
fi

if ! grep -i "Do not run \`git commit\`" "$DIRECTIVES_FILE" >/dev/null; then
    echo "FAIL: Directives file must explicitly forbid running git commit in negative constraints"
    exit 1
fi

if ! grep -i "Do not leave temporary files" "$DIRECTIVES_FILE" >/dev/null; then
    echo "FAIL: Directives file must explicitly forbid leaving temporary files in negative constraints"
    exit 1
fi

# Step 3: Run enable_suite to simulate deployment
export AI_SUITE_DRY_RUN=1
bash ai-suite enable --scope global --agent cursor >/dev/null || true

echo "PASS: Agent directives validation test passed."
exit 0
