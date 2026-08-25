#!/bin/bash
set -euo pipefail
set -e

RULE_FILE=".ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md"

if ! grep -q "output the execution summary as normal text AND call a minor tool" "$RULE_FILE"; then
  echo "FAIL: The interactive-workflow rule does not contain the correct AskQuestion batching instruction."
  exit 1
fi

if grep -q "You MUST first end your turn" "$RULE_FILE"; then
  echo "FAIL: The interactive-workflow rule still contains the 'end your turn' bug."
  exit 1
fi

echo "PASS: interactive-workflow rule has correct AskQuestion batching constraints."
