#!/usr/bin/env bash
set -euo pipefail

# This script validates the Gherkin feature file using grep to ensure it has required scenarios
FEATURE_FILE="tests/test-unified-workflow.feature"

if [[ ! -f "$FEATURE_FILE" ]]; then
  echo "FAIL: Feature file not found."
  exit 1
fi

scenarios=(
  "Scenario: Enable the AI suite"
  "Scenario: Disable the AI suite"
  "Scenario: Publish the AI suite"
  "Scenario: Evolve the AI suite"
  "Scenario: Guide AI suite development"
)

for s in "${scenarios[@]}"; do
  if ! grep -q "$s" "$FEATURE_FILE"; then
    echo "FAIL: Missing scenario: $s"
    exit 1
  fi
done

echo "PASS: Requirements Validation"
exit 0
