#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL="$SUITE_ROOT/.ai-suite/layer1-abstraction/agents/cursor/skills/ai-suite-architect.md"

if grep -q "Skill Semantic Strictness" "$SKILL"; then
  echo "PASS: ai-suite-architect enforces semantic strictness"
  exit 0
else
  echo "FAIL: ai-suite-architect missing semantic strictness rule"
  exit 1
fi
