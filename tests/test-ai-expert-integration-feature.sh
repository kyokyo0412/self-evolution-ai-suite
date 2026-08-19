#!/bin/bash
set -e

FEATURE_FILE="tests/ai-expert-integration.feature"

if [ ! -f "$FEATURE_FILE" ]; then
  echo "Error: $FEATURE_FILE does not exist"
  exit 1
fi

if ! grep -q "Scenario: AI-Expert is involved in the Reflection Protocol" "$FEATURE_FILE"; then
  echo "Error: Missing Reflection Protocol scenario"
  exit 1
fi

if ! grep -q "Scenario: AI-Expert is involved in the Global Workflow" "$FEATURE_FILE"; then
  echo "Error: Missing Global Workflow scenario"
  exit 1
fi

if ! grep -q "Scenario: AI-Expert is involved in Team Processes" "$FEATURE_FILE"; then
  echo "Error: Missing Team Processes scenario"
  exit 1
fi

echo "Feature file validation passed."
exit 0
