#!/usr/bin/env bash
set -e

echo "Running integrate-capability EUT..."

# 1. Test skill existence and frontmatter
if [[ ! -f ".ai-suite/layer4-evolutionary/merging/integrate-capability.md" ]]; then
    echo "FAIL: integrate-capability skill missing"
    exit 1
fi

if ! grep -q "name: integrate-capability" ".ai-suite/layer4-evolutionary/merging/integrate-capability.md"; then
    echo "FAIL: integrate-capability skill missing name frontmatter"
    exit 1
fi

echo "PASS: integrate-capability EUT validated"
exit 0
