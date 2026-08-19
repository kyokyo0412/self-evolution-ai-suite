#!/usr/bin/env bash
# test-evolution-semantics-contracts.sh

set -euo pipefail

echo "Running Evolution Semantics Contract Tests..."

REFLECTION_FILE=".ai-suite/layer4-evolutionary/reflection/reflection-protocol.md"
EVOLVE_SKILL=".ai-suite/layer4-evolutionary/merging/evolve-collect.md"

if [[ ! -f "$REFLECTION_FILE" ]]; then
  echo "FAIL: $REFLECTION_FILE not found"
  exit 1
fi

# 1. Semantic Understanding
if ! grep -qi "semantic understanding" "$REFLECTION_FILE"; then
  echo "FAIL: reflection-protocol.md does not mandate 'semantic understanding'"
  exit 1
fi

# 2. Agent Effectiveness (understand and process prompts/skills/rules better)
if ! grep -qi "process the prompt, skills, rules" "$REFLECTION_FILE"; then
  echo "FAIL: reflection-protocol.md does not mandate improving how the agent understands/processes prompts, skills, rules"
  exit 1
fi

# 3. End-User Usability
if ! grep -qi "easy by the end user" "$REFLECTION_FILE"; then
  echo "FAIL: reflection-protocol.md does not mandate making the suite easy to use by the end user"
  exit 1
fi

echo "PASS: Evolution Semantics Contract Tests"
exit 0
