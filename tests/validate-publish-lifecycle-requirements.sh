#!/usr/bin/env bash
set -euo pipefail

FEATURE_FILE="tests/publish-and-lifecycle.feature"

echo "=== [SDET Gate] Validating Publish and Lifecycle Requirements ==="

if [[ ! -f "$FEATURE_FILE" ]]; then
  echo "FAIL: Feature file missing: $FEATURE_FILE"
  exit 1
fi

grep -qi "Scenario: Publish packages the full framework" "$FEATURE_FILE" || { echo "FAIL: Missing publish scenario"; exit 1; }
grep -qi "Scenario: Project-level installation and isolation" "$FEATURE_FILE" || { echo "FAIL: Missing project enable scenario"; exit 1; }
grep -qi "Scenario: Project-level uninstallation symmetry" "$FEATURE_FILE" || { echo "FAIL: Missing project disable scenario"; exit 1; }
grep -qi "Scenario: Global install and uninstall lifecycle" "$FEATURE_FILE" || { echo "FAIL: Missing global lifecycle scenario"; exit 1; }

echo "PASS: Publish & Lifecycle requirements verified."
exit 0
