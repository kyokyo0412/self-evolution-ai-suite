#!/usr/bin/env bash
set -euo pipefail

SKILL_FILE=".ai-suite/layer4-evolutionary/merging/absorb-capability.md"

echo "Running Unit Tests for Absorb Capability Skill..."

if [[ ! -f "$SKILL_FILE" ]]; then
  echo "FAIL: Skill file $SKILL_FILE missing."
  exit 1
fi

# Check for Semantic Analysis requirement
if ! grep -qi "Robust Semantic Mapping & Deep Learning" "$SKILL_FILE"; then
  echo "FAIL: Skill does not mandate 'Robust Semantic Mapping & Deep Learning'."
  exit 1
fi
if ! grep -qi "semantic map" "$SKILL_FILE"; then
  echo "FAIL: Skill does not mandate 'semantic map'."
  exit 1
fi

# Check for Deep Architectural Integration requirement
if ! grep -qi "Fundamentally Grounded Semantic Integration" "$SKILL_FILE"; then
  echo "FAIL: Skill does not mandate 'Fundamentally Grounded Semantic Integration'."
  exit 1
fi
if ! grep -qi "synthesize and master" "$SKILL_FILE"; then
  echo "FAIL: Skill does not mandate to 'synthesize and master' architectures."
  exit 1
fi

# Check for Evolution Verification (TDD) requirement
if ! grep -qi "Evolution Verification (TDD)" "$SKILL_FILE"; then
  echo "FAIL: Skill does not mandate 'Evolution Verification (TDD)'."
  exit 1
fi

# Check for Evolution Reporting requirement
if ! grep -qi "Evolution Reporting" "$SKILL_FILE"; then
  echo "FAIL: Skill does not mandate 'Evolution Reporting'."
  exit 1
fi

echo "PASS: Absorb Capability Skill meets all V2 requirements."
exit 0
