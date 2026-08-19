#!/bin/bash
# Phase 1: Validate Executable Specifications for Proactive Agent

# Simple parser to ensure the feature file contains the required keywords
FEATURE_FILE="tests/proactive-agent.feature"

if [ ! -f "$FEATURE_FILE" ]; then
  echo "FAIL: Feature file missing."
  exit 1
fi

REQUIRED_WORDS=("Feature:" "Scenario:" "Given" "When" "Then" "And" "proactively" "iterate" "analyze" "devise" "attempt" "alternative approaches" "report" "evolution")

for word in "${REQUIRED_WORDS[@]}"; do
  if ! grep -q "$word" "$FEATURE_FILE"; then
    echo "FAIL: Missing required keyword or concept in specs: '$word'"
    exit 1
  fi
done

echo "PASS: Proactive Agent Executable Specifications validated."
exit 0
