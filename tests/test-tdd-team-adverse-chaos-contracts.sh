#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-adverse-chaos-contracts.sh
# Validates chaos, adverse state, and boundary fuzzing coverage in tdd-team skill

check_adverse_chaos_contracts() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating Adverse Chaos & Boundary Fuzzing contracts in: $file"

  # 1. Chaos & Fault Injection
  if ! grep -qi "Chaos" "$file" || ! grep -qi "Fault Injection" "$file"; then
    echo "  FAIL: Chaos / Fault injection criteria missing in $file"
    return 1
  fi

  # 2. Boundary Value Analysis (BVA) & Equivalence Partitioning
  if ! grep -qi "BVA" "$file" || ! grep -qi "Equivalence" "$file"; then
    echo "  FAIL: BVA & Equivalence Partitioning criteria missing in $file"
    return 1
  fi

  # 3. AI Stream Latency & Offline Recovery
  if ! grep -qi "streaming.*latency\|offline" "$file"; then
    echo "  FAIL: AI stream latency / offline handling criteria missing in $file"
    return 1
  fi

  # 4. Domain Adversarial Chaos & Fault Injection Gate (Order-3 Hardening)
  echo "  Checking Domain Adversarial Chaos & Fault Injection in Phase 4..."
  if ! grep -qi "domain chaos injection" "$file"; then
    echo "  FAIL: 'domain chaos injection' missing in $file"
    return 1
  fi
  if ! grep -qi "network partition simulation" "$file"; then
    echo "  FAIL: 'network partition simulation' missing in $file"
    return 1
  fi
  if ! grep -qi "malformed protocol frame injection" "$file"; then
    echo "  FAIL: 'malformed protocol frame injection' missing in $file"
    return 1
  fi
  if ! grep -qi "clock jitter" "$file"; then
    echo "  FAIL: 'clock jitter' missing in $file"
    return 1
  fi

  echo "  PASS: Adverse Chaos & Boundary Fuzzing contracts verified for $file"
  return 0
}

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

if [ "$#" -gt 0 ]; then
  check_adverse_chaos_contracts "$1"
  exit $?
fi

PASS_COUNT=0
FAIL_COUNT=0

if check_adverse_chaos_contracts "$TARGET_SOURCE"; then
  PASS_COUNT=$((PASS_COUNT + 1))
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if [ -f "$TARGET_CURSOR" ]; then
  if check_adverse_chaos_contracts "$TARGET_CURSOR"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ -f "$TARGET_CODEX" ]; then
  if check_adverse_chaos_contracts "$TARGET_CODEX"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed Adverse Chaos contract verification."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT checked files passed Adverse Chaos contract verification."
exit 0
