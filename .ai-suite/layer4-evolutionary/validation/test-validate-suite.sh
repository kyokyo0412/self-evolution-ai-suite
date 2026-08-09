#!/usr/bin/env bash
set -euo pipefail

TARGET_SCRIPT=".ai-suite/layer4-evolutionary/validation/validate-suite.sh"

echo "Running self-test for $TARGET_SCRIPT..."

if [[ ! -f "$TARGET_SCRIPT" ]]; then
  echo "FAIL: $TARGET_SCRIPT not found"
  exit 1
fi

# Run the target script and capture output (both stdout and stderr)
set +e
output=$(bash "$TARGET_SCRIPT" 2>&1)
exit_code=$?
set -e

# We expect the script to succeed (exit code 0 if all skills are valid)
if [[ $exit_code -ne 0 ]]; then
  echo "FAIL: $TARGET_SCRIPT exited with code $exit_code"
  echo "Output:"
  echo "$output"
  exit 1
fi

# Check for the regression: "command not found" caused by $(_grn) instead of $C_GRN
if echo "$output" | grep -iq "command not found"; then
  echo "FAIL: Found 'command not found' in output!"
  echo "Output snippet:"
  echo "$output" | grep -i -C 2 "command not found"
  exit 1
fi

if ! echo "$output" | grep -iq "checks passed"; then
  echo "FAIL: Did not find 'checks passed' in output."
  echo "Output snippet:"
  echo "$output" | tail -n 5
  exit 1
fi

echo "PASS: validate-suite.sh runs cleanly without command errors."
exit 0
