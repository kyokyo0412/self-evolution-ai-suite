#!/bin/bash
set -e

REFLECTION=".ai-suite/layer4-evolutionary/reflection/reflection-protocol.md"
CORE_LIB=".ai-suite/layer2-cognitive/memory/core.sh"
TDD_TEAM=".ai-suite/layer3-registry/core/tdd-team.md"
AUTO_TEAM=".ai-suite/layer3-registry/core/autonomous-team.md"

# 1. Check Reflection Protocol
if ! grep -qi "ai-expert" "$REFLECTION"; then
  echo "Error: AI-Expert not integrated into $REFLECTION"
  exit 1
fi

# 2. Check Global Block in core.sh
if ! grep -qi "AI-Expert Prompt Optimization" "$CORE_LIB"; then
  echo "Error: AI-Expert Prompt Optimization not integrated into $CORE_LIB"
  exit 1
fi

# 3. Check TDD Team
if ! grep -qi "ai-expert" "$TDD_TEAM"; then
  echo "Error: AI-Expert not integrated into $TDD_TEAM"
  exit 1
fi

# 4. Check Autonomous Team
if ! grep -qi "ai-expert" "$AUTO_TEAM"; then
  echo "Error: AI-Expert not integrated into $AUTO_TEAM"
  exit 1
fi

echo "AI-Expert integration tests passed."
exit 0
