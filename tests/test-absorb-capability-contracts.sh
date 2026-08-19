#!/usr/bin/env bash
# test-absorb-capability-contracts.sh

set -euo pipefail

echo "Running Absorb Capability Contract Tests..."

SKILL_FILE=".ai-suite/layer4-evolutionary/merging/absorb-capability.md"

if [[ ! -f "$SKILL_FILE" ]]; then
  echo "FAIL: $SKILL_FILE not found"
  exit 1
fi

if ! grep -q "AI suite Agent" "$SKILL_FILE"; then
  echo "FAIL: absorb-capability.md does not mention 'AI suite Agent'"
  exit 1
fi

if ! grep -q "AI suite developing agent" "$SKILL_FILE"; then
  echo "FAIL: absorb-capability.md does not mention 'AI suite developing agent'"
  exit 1
fi

if ! grep -qi "own configuration" "$SKILL_FILE"; then
  echo "FAIL: absorb-capability.md does not mention merging into its own configuration"
  exit 1
fi

echo "PASS: Absorb Capability Contract Tests"
