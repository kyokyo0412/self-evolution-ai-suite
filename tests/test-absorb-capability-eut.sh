#!/usr/bin/env bash
set -uo pipefail

echo "Running absorb capabilities EUT..."

# Check skill file existence
if [[ ! -f ".ai-suite/layer4-evolutionary/merging/absorb-capability.md" ]]; then
  echo "FAIL: .ai-suite/layer4-evolutionary/merging/absorb-capability.md does not exist."
  exit 1
fi

if ! grep -qi "semantic review" ".ai-suite/layer4-evolutionary/merging/absorb-capability.md" && ! grep -qi "semantic map" ".ai-suite/layer4-evolutionary/merging/absorb-capability.md"; then
  echo "FAIL: .ai-suite/layer4-evolutionary/merging/absorb-capability.md missing semantic review requirement."
  exit 1
fi

if ! grep -qi "synthetically unify" ".ai-suite/layer4-evolutionary/merging/absorb-capability.md" && ! grep -qi "synthesize and master" ".ai-suite/layer4-evolutionary/merging/absorb-capability.md"; then
  echo "FAIL: .ai-suite/layer4-evolutionary/merging/absorb-capability.md missing synthetically unify requirement."
  exit 1
fi

echo "PASS: All tests passed!"
exit 0
