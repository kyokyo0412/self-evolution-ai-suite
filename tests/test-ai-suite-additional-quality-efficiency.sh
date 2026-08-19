#!/bin/bash
set -e

echo "Running Additional TDD Team and AI Expert Quality/Efficiency Tests..."

AUTONOMOUS_TEAM=".ai-suite/layer3-registry/core/autonomous-team.md"
AUTOMATED_REVIEWER=".ai-suite/layer3-registry/core/automated-code-reviewer.md"

if [ ! -f "$AUTONOMOUS_TEAM" ]; then
    echo "ERROR: $AUTONOMOUS_TEAM does not exist."
    exit 1
fi

if [ ! -f "$AUTOMATED_REVIEWER" ]; then
    echo "ERROR: $AUTOMATED_REVIEWER does not exist."
    exit 1
fi

echo "Checking autonomous-team/SKILL.md for 'parallel tool calls'..."
if ! grep -iq "parallel tool calls" "$AUTONOMOUS_TEAM"; then
    echo "ERROR: autonomous-team/SKILL.md does not enforce parallel tool calls."
    exit 1
fi

echo "Checking autonomous-team/SKILL.md for 'ReadLints' or 'linter checks'..."
if ! grep -iqE "ReadLints|linter checks" "$AUTONOMOUS_TEAM"; then
    echo "ERROR: autonomous-team/SKILL.md does not enforce linter checks."
    exit 1
fi

echo "Checking automated-code-reviewer/SKILL.md for 'parallel tool calls'..."
if ! grep -iq "parallel tool calls" "$AUTOMATED_REVIEWER"; then
    echo "ERROR: automated-code-reviewer/SKILL.md does not enforce parallel tool calls."
    exit 1
fi

echo "Checking automated-code-reviewer/SKILL.md for 'quality checks' or 'linter checks' or 'ReadLints'..."
if ! grep -iqE "quality checks|linter checks|ReadLints" "$AUTOMATED_REVIEWER"; then
    echo "ERROR: automated-code-reviewer/SKILL.md does not enforce quality/linter checks."
    exit 1
fi

AI_REVIEW_FIX=".ai-suite/layer3-registry/core/ai-review-fix.md"
AI_REVIEW_FIX_MANUAL=".ai-suite/layer3-registry/core/ai-review-fix-manual.md"

echo "Checking ai-review-fix/SKILL.md for 'parallel tool calls'..."
if ! grep -iq "parallel tool calls" "$AI_REVIEW_FIX"; then
    echo "ERROR: ai-review-fix/SKILL.md does not enforce parallel tool calls."
    exit 1
fi

echo "Checking ai-review-fix-manual/SKILL.md for 'parallel tool calls'..."
if ! grep -iq "parallel tool calls" "$AI_REVIEW_FIX_MANUAL"; then
    echo "ERROR: ai-review-fix-manual/SKILL.md does not enforce parallel tool calls."
    exit 1
fi

echo "SUCCESS: AI Suite Additional Quality and Efficiency contracts verified."
exit 0
