#!/usr/bin/env bash
set -euo pipefail

echo "Running Workflow E2E tests..."

# Mock an external agent layout
TMP_MOCK=$(mktemp -d "${TMPDIR:-/tmp}/ai-suite-mock-XXXXXX")
trap "rm -rf '$TMP_MOCK'" EXIT

mkdir -p "$TMP_MOCK/.claude/skills/mock-skill"
cat << 'EOF' > "$TMP_MOCK/.claude/skills/mock-skill/SKILL.md"
---
name: mock-skill
---
Mock content
EOF

# Test Absorb
echo "Testing Absorb..."
OUTPUT=$(./ai-suite workflow absorb --local-path "$TMP_MOCK" 2>&1)

if ! echo "$OUTPUT" | grep -q "prompt your AI agent to perform semantic absorption"; then
    echo "FAIL: Absorb did not output semantic instructions for AI agent"
    echo "$OUTPUT"
    exit 1
fi

echo "Absorb PASS."

# Mock integrate target
mkdir -p "$TMP_MOCK/integrate_target"

# Test Integrate
echo "Testing Integrate..."
OUTPUT=$(./ai-suite workflow integrate --host localhost --remote-path /tmp/foo 2>&1)

if ! echo "$OUTPUT" | grep -q "prompt your AI agent to perform semantic integration"; then
    echo "FAIL: Integrate did not output semantic instructions for AI agent"
    echo "$OUTPUT"
    exit 1
fi

echo "Integrate PASS."

# Test Enable (dry-run)
echo "Testing Enable..."
OUTPUT=$(./ai-suite workflow enable --agent cursor --scope project --dry-run 2>&1)
if ! echo "$OUTPUT" | grep -q "enable_suite"; then
    echo "FAIL: Enable did not seem to delegate to ai-suite enable"
    echo "$OUTPUT"
    exit 1
fi
echo "Enable PASS."

# Test Disable (dry-run)
echo "Testing Disable..."
OUTPUT=$(./ai-suite workflow disable --agent cursor --scope project --dry-run 2>&1)
if ! echo "$OUTPUT" | grep -q "disable_suite"; then
    echo "FAIL: Disable did not seem to delegate to ai-suite disable"
    echo "$OUTPUT"
    exit 1
fi
echo "Disable PASS."

# Test Publish (dry-run)
echo "Testing Publish..."
OUTPUT=$(./ai-suite workflow publish --dry-run 2>&1 || true)
if ! echo "$OUTPUT" | grep -q "Workflow: Publish"; then
    echo "FAIL: Publish did not seem to delegate to ai-suite publish"
    echo "$OUTPUT"
    exit 1
fi
echo "Publish PASS."

# Test Develop
echo "Testing Develop..."
OUTPUT=$(./ai-suite workflow develop 2>&1 || true)
if ! echo "$OUTPUT" | grep -q "AI Suite Development"; then
    echo "FAIL: Develop did not output instructions"
    echo "$OUTPUT"
    exit 1
fi
echo "Develop PASS."

# Cleanup
rm -f ".ai-suite/layer3-registry/core/mock-skill.md"

echo "PASS: Workflow E2E"
exit 0
