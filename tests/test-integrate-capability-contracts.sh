#!/usr/bin/env bash
# test-integrate-capability-contracts.sh

set -euo pipefail

echo "Running Integrate Capability Contract Tests..."

SKILL_FILE=".ai-suite/layer4-evolutionary/merging/integrate-capability.md"

if [[ ! -f "$SKILL_FILE" ]]; then
  echo "FAIL: $SKILL_FILE not found"
  exit 1
fi

if ! grep -q "AI suite Agent" "$SKILL_FILE"; then
  echo "FAIL: integrate-capability.md does not mention 'AI suite Agent'"
  exit 1
fi

if ! grep -qi "own capabilities" "$SKILL_FILE"; then
  echo "FAIL: integrate-capability.md does not mention 'its own capabilities'"
  exit 1
fi

if ! grep -qi "transforming the external agent" "$SKILL_FILE"; then
  echo "FAIL: integrate-capability.md does not mention transforming the external agent"
  exit 1
fi

echo "PASS: Integrate Capability Contract Tests"
