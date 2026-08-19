#!/bin/bash
set -e

FEATURE_FILE="tests/ai-expert.feature"

if [ ! -f "$FEATURE_FILE" ]; then
  echo "Error: $FEATURE_FILE does not exist"
  exit 1
fi

if ! grep -q "Feature: AI-Expert Role" "$FEATURE_FILE"; then
  echo "Error: Missing Feature definition"
  exit 1
fi

if ! grep -q "Scenario: AI-Expert skill is available as a core skill" "$FEATURE_FILE"; then
  echo "Error: Missing Scenario definition"
  exit 1
fi

echo "Feature file validation passed."
exit 0
