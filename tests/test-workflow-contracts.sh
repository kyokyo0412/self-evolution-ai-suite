#!/usr/bin/env bash
set -euo pipefail

echo "Running Workflow Contracts tests..."

# Check that script exists
if [[ ! -x "ai-suite" || ! -f ".ai-suite/cli/workflow.sh" ]]; then
    echo "FAIL: ai-suite workflow does not exist or is not executable"
    exit 1
fi

echo "Testing 'evolve' command interface..."
if ! ./ai-suite workflow evolve --dry-run >/dev/null; then
    echo "FAIL: evolve command rejected"
    exit 1
fi

echo "Testing 'absorb' command interface..."
if ! ./ai-suite workflow absorb --local --dry-run >/dev/null; then
    echo "FAIL: absorb command rejected"
    exit 1
fi

echo "Testing 'integrate' command interface..."
if ! ./ai-suite workflow integrate --host user@test --remote-path /test --dry-run >/dev/null; then
    echo "FAIL: integrate command rejected"
    exit 1
fi

echo "Testing 'enable' command interface..."
if ! ./ai-suite workflow enable --agent cursor --scope global --dry-run >/dev/null; then
    echo "FAIL: enable command rejected"
    exit 1
fi

echo "Testing 'disable' command interface..."
if ! ./ai-suite workflow disable --agent cursor --scope global --dry-run >/dev/null; then
    echo "FAIL: disable command rejected"
    exit 1
fi

echo "Testing 'publish' command interface..."
if ! ./ai-suite workflow publish --dry-run >/dev/null; then
    echo "FAIL: publish command rejected"
    exit 1
fi

echo "Testing 'develop' command interface..."
if ! ./ai-suite workflow develop --dry-run >/dev/null; then
    echo "FAIL: develop command rejected"
    exit 1
fi

echo "PASS: Workflow contracts"
exit 0
