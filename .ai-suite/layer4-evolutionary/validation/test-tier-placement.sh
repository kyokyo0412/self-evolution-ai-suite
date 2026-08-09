#!/bin/bash
set -e

REFLECTION_PROTOCOL=".ai-suite/layer4-evolutionary/reflection/reflection-protocol.md"
ARCHITECT_SKILL=".ai-suite/layer1-abstraction/agents/cursor/skills/ai-suite-architect.md"

if ! grep -q "Tier Accuracy" "$REFLECTION_PROTOCOL"; then
  echo "Error: Tier Accuracy missing from reflection protocol"
  exit 1
fi

if ! grep -q "Generality Gate" "$ARCHITECT_SKILL"; then
  echo "Error: Generality Gate missing from ai-suite-architect"
  exit 1
fi

echo "Tier placement tests passed."
exit 0