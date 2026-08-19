#!/usr/bin/env bash
set -e

echo "Validating BDD feature files for content-based matching requirement..."

if ! grep -q "based on file content comparison" tests/absorb-capability.feature; then
    echo "FAIL: absorb-capability.feature missing content comparison requirement"
    exit 1
fi

if ! grep -q "based on file content comparison" tests/integrate-capability.feature; then
    echo "FAIL: integrate-capability.feature missing content comparison requirement"
    exit 1
fi

echo "PASS: Phase 1 BDD validation passed"
exit 0
