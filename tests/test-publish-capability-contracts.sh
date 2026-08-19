#!/usr/bin/env bash
# test-publish-capability-contracts.sh

set -euo pipefail

echo "Running Publish Capability Contract Tests..."

SKILL_FILE=".ai-suite/layer4-evolutionary/merging/publish-capability.md"

if [[ ! -f "$SKILL_FILE" ]]; then
  echo "FAIL: $SKILL_FILE not found"
  exit 1
fi

if ! grep -q "AI suite Agent" "$SKILL_FILE"; then
  echo "FAIL: publish-capability.md does not mention 'AI suite Agent'"
  exit 1
fi

if ! grep -q "publish package" "$SKILL_FILE"; then
  echo "FAIL: publish-capability.md does not mention 'publish package'"
  exit 1
fi

echo "PASS: Publish Capability Contract Tests"
