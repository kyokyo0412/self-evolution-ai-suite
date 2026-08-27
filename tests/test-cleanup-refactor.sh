#!/usr/bin/env bash
set -euo pipefail

echo "Running cleanup and refactoring validation tests..."

# Check if core scripts exist and are executable
for script in ai-suite .ai-suite/cli/evolve.sh .ai-suite/cli/enable.sh .ai-suite/cli/disable.sh .ai-suite/cli/workflow.sh; do
  if [[ ! -x "$script" ]]; then
    echo "FAIL: $script is missing or not executable"
    exit 1
  fi
done

# Verify self-evolution core function (dry-run)
if ! ./ai-suite evolve collect --host dummy@localhost --dry-run > /dev/null; then
  echo "FAIL: ai-suite evolve collect dry-run failed"
  exit 1
fi

# Verify tdd-team skill exists and is intact
TDD_SKILL=".ai-suite/layer3-registry/core/tdd-team.md"
if [[ ! -f "$TDD_SKILL" ]]; then
  echo "FAIL: tdd-team skill is missing"
  exit 1
fi

if ! grep -q "Phase 1" "$TDD_SKILL"; then
  echo "FAIL: tdd-team skill is broken (missing Phase 1)"
  exit 1
fi

echo "PASS: Cleanup and refactoring validation passed"
exit 0
