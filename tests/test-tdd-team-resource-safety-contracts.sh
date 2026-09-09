#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-resource-safety-contracts.sh
# Validates resource lifecycle and 1E-class safety compliance in tdd-team skill

check_resource_safety_contracts() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating Resource Safety & 1E-Class Safety contracts in: $file"

  # 1. Resource & Memory Safety
  if ! grep -qi "Resource & Memory Safety\|resource leak" "$file"; then
    echo "  FAIL: Resource and memory safety criteria missing in $file"
    return 1
  fi

  # 2. 1E-Class Security & Deterministic Execution
  if ! grep -qi "1E-Class" "$file"; then
    echo "  FAIL: 1E-Class Security criteria missing in $file"
    return 1
  fi

  # 3. Deterministic Error Handling & Bounded Resources
  if ! grep -qi "swallowed" "$file" || ! grep -qi "bounded" "$file"; then
    echo "  FAIL: Swallowed error prevention or bounded resource criteria missing in $file"
    return 1
  fi

  # 4. Domain Resource Safety & 1E-Class Deterministic Bounds (Order-4 Hardening)
  echo "  Checking Domain Resource Safety & 1E-Class Deterministic Bounds..."
  if ! grep -qi "1E-Class Security Standards" "$file"; then
    echo "  FAIL: 1E-Class Security Standards missing in $file"
    return 1
  fi
  if ! grep -qi "zero resource leaks" "$file" || ! grep -qi "bounded buffer allocations" "$file"; then
    echo "  FAIL: Bounded allocations / zero resource leaks missing in $file"
    return 1
  fi
  if ! grep -qi "deterministic execution" "$file" && ! grep -qi "deterministic error handling" "$file"; then
    echo "  FAIL: Deterministic execution criteria missing in $file"
    return 1
  fi
  if ! grep -qi "payload bounds" "$file"; then
    echo "  FAIL: Domain NFR bounds (payload bounds) missing in $file"
    return 1
  fi

  # Check line-level 1E-class bounding in Phase 3.5
  if ! grep -qi "Resource & Memory Safety (1E-Class Standards)" "$file"; then
    echo "  FAIL: Phase 3.5 Resource & Memory Safety (1E-Class Standards) missing in $file"
    return 1
  fi
  if ! grep -qi "deterministic execution time enforcement" "$file"; then
    echo "  FAIL: Phase 3.5 deterministic execution time enforcement missing in $file"
    return 1
  fi

  echo "  PASS: Resource Safety & 1E-Class Safety contracts verified for $file"
  return 0
}

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

if [ "$#" -gt 0 ]; then
  check_resource_safety_contracts "$1"
  exit $?
fi

PASS_COUNT=0
FAIL_COUNT=0

if check_resource_safety_contracts "$TARGET_SOURCE"; then
  PASS_COUNT=$((PASS_COUNT + 1))
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if [ -f "$TARGET_CURSOR" ]; then
  if check_resource_safety_contracts "$TARGET_CURSOR"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ -f "$TARGET_CODEX" ]; then
  if check_resource_safety_contracts "$TARGET_CODEX"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed Resource Safety verification."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT checked files passed Resource Safety verification."
exit 0
