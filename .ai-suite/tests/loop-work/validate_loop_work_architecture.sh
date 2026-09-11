#!/bin/bash
set -euo pipefail

SKILL_FILE=".ai-suite/layer3-registry/core/loop-work.md"

if [ ! -f "$SKILL_FILE" ]; then
  echo "RED: $SKILL_FILE does not exist."
  exit 1
fi

echo "Validating loop-work.md architecture..."

# 1. Check if Continuation Protocol section exists
if ! grep -qi "Continuation Protocol" "$SKILL_FILE"; then
  echo "RED: Missing Continuation Protocol section."
  exit 1
fi

# 2. Check if Progressive Hardening Framework section exists
if ! grep -qi "Progressive Hardening Framework" "$SKILL_FILE"; then
  echo "RED: Missing Progressive Hardening Framework section."
  exit 1
fi

# 3. Check if Execution Protocol section exists
if ! grep -qi "Execution Protocol" "$SKILL_FILE"; then
  echo "RED: Missing Execution Protocol section."
  exit 1
fi

# 4. Check for Identical Full Task Iteration Invariant section
if ! grep -qi "Identical Full Task Iteration Invariant" "$SKILL_FILE"; then
  echo "RED: Missing Identical Full Task Iteration Invariant section."
  exit 1
fi

# 5. Check for State Tracking section
if ! grep -qi "State Tracking" "$SKILL_FILE"; then
  echo "RED: Missing State Tracking section."
  exit 1
fi

echo "GREEN: Architecture validation passed."
exit 0
