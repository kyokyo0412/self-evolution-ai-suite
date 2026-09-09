#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-concurrency-race-contracts.sh
# Validates concurrency, parallelism, and race safety contracts in tdd-team skill

check_concurrency_race_contracts() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating Concurrency, Parallelism & Race Safety in: $file"

  # 1. Parallel Tool Calls & Parallel Processing
  if ! grep -qi "parallel" "$file"; then
    echo "  FAIL: Parallel execution criteria missing in $file"
    return 1
  fi

  # 2. Concurrency & Race Safety
  if ! grep -qi "Concurrency" "$file" || ! grep -qi "race" "$file"; then
    echo "  FAIL: Concurrency and race safety criteria missing in $file"
    return 1
  fi

  # 3. Optimistic Mutation Rollbacks
  if ! grep -qi "optimistic" "$file"; then
    echo "  FAIL: Optimistic mutation criteria missing in $file"
    return 1
  fi

  # 4. Domain-Specific Concurrency & Race Hazards (Order-3 Hardening)
  echo "  Checking Domain-Specific Concurrency & Race Hazards..."
  if ! grep -qi "race conditions in inventory" "$file" || ! grep -qi "concurrent checkout" "$file"; then
    echo "  FAIL: Domain-specific concurrency failure modes missing in $file"
    return 1
  fi
  if ! grep -qi "concurrent.*failure modes into executable\|concurrent checkout" "$file"; then
    echo "  FAIL: Executable concurrent test scenarios mandate missing in $file"
    return 1
  fi
  if ! grep -qi "distributed lock leases" "$file" || ! grep -qi "idempotency tokens" "$file" || ! grep -qi "atomic order book" "$file"; then
    echo "  FAIL: Domain-specific concurrency topologies (distributed lock leases, idempotency tokens, atomic order book) missing in $file"
    return 1
  fi
  if ! grep -qi "preventing double-spend" "$file" || ! grep -qi "inventory race conditions" "$file"; then
    echo "  FAIL: Domain concurrency hazard mitigation in code review missing in $file"
    return 1
  fi

  echo "  PASS: Concurrency, Parallelism & Race Safety contracts verified for $file"
  return 0
}

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

if [ "$#" -gt 0 ]; then
  check_concurrency_race_contracts "$1"
  exit $?
fi

PASS_COUNT=0
FAIL_COUNT=0

if check_concurrency_race_contracts "$TARGET_SOURCE"; then
  PASS_COUNT=$((PASS_COUNT + 1))
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if [ -f "$TARGET_CURSOR" ]; then
  if check_concurrency_race_contracts "$TARGET_CURSOR"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ -f "$TARGET_CODEX" ]; then
  if check_concurrency_race_contracts "$TARGET_CODEX"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed Concurrency & Race Safety verification."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT checked files passed Concurrency & Race Safety verification."
exit 0
