#!/usr/bin/env bash
set -euo pipefail

echo "Running isolation tests..."

# Test 1: ai-suite enable should fail if --scope project is used in the source repo
if bash ai-suite enable --scope project --agent cursor >/dev/null 2>&1; then
    echo "FAIL: ai-suite enable allowed --scope project in the source repo."
    exit 1
else
    echo "PASS: ai-suite enable correctly refused --scope project in the source repo."
fi

# Test 2: clean_dev_env.sh should exist and be executable
if [[ ! -x "scripts/clean_dev_env.sh" ]]; then
    echo "FAIL: scripts/clean_dev_env.sh does not exist or is not executable."
    exit 1
else
    echo "PASS: scripts/clean_dev_env.sh exists and is executable."
fi

# Test 3: ai-suite evolve collect --local should exist
if ! grep -q "COLLECT_LOCAL" .ai-suite/cli/evolve.sh; then
    echo "FAIL: ai-suite evolve does not have collect_local functionality."
    exit 1
else
    echo "PASS: ai-suite evolve has collect_local functionality."
fi

echo "All isolation tests passed."
exit 0
