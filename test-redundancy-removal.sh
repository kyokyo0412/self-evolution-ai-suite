#!/bin/bash
set -e

echo "Running Redundancy Removal Test..."

# 1. Check for deleted files
if [ -f ".ai-suite/layer2-cognitive/meta-compiler/ai-expert.md" ]; then
    echo "FAIL: ai-expert.md still exists."
    exit 1
fi

if [ -f ".ai-suite/layer3-registry/core/ai-review-fix-manual.md" ]; then
    echo "FAIL: ai-review-fix-manual.md still exists."
    exit 1
fi

# 2. Check for merged files
if [ ! -f ".ai-suite/layer2-cognitive/meta-compiler/prompt-compiler.md" ]; then
    echo "FAIL: prompt-compiler.md does not exist."
    exit 1
fi

if [ ! -f ".ai-suite/layer3-registry/core/ai-review-fix.md" ]; then
    echo "FAIL: ai-review-fix.md does not exist."
    exit 1
fi

# 3. Check README.md
if grep -q "ai-expert" README.md; then
    echo "FAIL: README.md still references ai-expert."
    exit 1
fi

if grep -q "ai-review-fix-manual" README.md; then
    echo "FAIL: README.md still references ai-review-fix-manual."
    exit 1
fi

# 4. Run suite validation
echo "Running suite validation..."
bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh

echo "All tests PASSED."
