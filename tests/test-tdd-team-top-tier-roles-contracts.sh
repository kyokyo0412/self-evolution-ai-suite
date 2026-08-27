#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-top-tier-roles-contracts.sh
# Validates that all roles in the tdd-team skill are described as top-tier, experienced industry professionals
# with deep domain competence, rigorous review criteria, and uncompromising standards.

check_top_tier_role_contracts() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating top-tier industry role contracts in: $file"

  # 1. PM Role: Top-Tier Product Leader / Strategist
  echo "  Checking PM Role top-tier criteria..."
  if ! grep -qi "PM" "$file" || ! grep -qi "first-principles" "$file" || ! grep -qi "adversarial" "$file"; then
    echo "  FAIL: PM role does not satisfy top-tier industry standards (first-principles, adversarial edge cases) in $file"
    return 1
  fi
  if ! grep -qi "non-functional" "$file" || ! grep -qi "SLAs\|throughput\|concurrency" "$file"; then
    echo "  FAIL: PM role does not specify deep non-functional requirements in $file"
    return 1
  fi

  # 2. AI Expert Role: Distinguished AI Expert & Cognitive Architect
  echo "  Checking AI Expert Role top-tier criteria..."
  if ! grep -qi "AI Expert" "$file" || ! grep -qi "anti-hallucination" "$file" || ! grep -qi "cognitive" "$file"; then
    echo "  FAIL: AI Expert role does not satisfy top-tier cognitive architecture & anti-hallucination standards in $file"
    return 1
  fi

  # 3. Chief Reviewer Role: Distinguished Fellow / Chief Reviewer with absolute veto
  echo "  Checking Chief Reviewer Role top-tier criteria..."
  if ! grep -qi "veto" "$file"; then
    echo "  FAIL: Chief Reviewer role lacks absolute veto power in $file"
    return 1
  fi
  if ! grep -qi "luminary\|veteran\|fellow" "$file" || ! grep -qi "1E-Class" "$file"; then
    echo "  FAIL: Chief Reviewer role does not specify industry luminary / 1E-Class standards in $file"
    return 1
  fi

  # 4. Architect Role: Senior Principal Distributed Systems Architect
  echo "  Checking Systems Architect Role top-tier criteria..."
  if ! grep -qi "Architect" "$file" || ! grep -qi "blast radius" "$file" || ! grep -qi "circuit break\|backpressure\|idempotenc" "$file"; then
    echo "  FAIL: Architect role does not specify distributed systems failure containment / resilience standards in $file"
    return 1
  fi

  # 5. SDET Role: Senior Principal SDET & Chaos Gatekeeper
  echo "  Checking SDET Role top-tier criteria..."
  if ! grep -qi "SDET" "$file" || ! grep -qi "Chaos" "$file" || ! grep -qi "true purpose\|correctness of the requirement" "$file"; then
    echo "  FAIL: SDET role does not specify requirement correctness critique in $file"
    return 1
  fi
  if ! grep -qi "BVA" "$file" || ! grep -qi "Equivalence" "$file" || ! grep -qi "Fault Injection" "$file"; then
    echo "  FAIL: SDET role does not specify BVA, Equivalence, and Fault Injection in $file"
    return 1
  fi

  # 6. Developer Role: Staff/Principal Core Systems Software Engineer
  echo "  Checking Developer Role top-tier criteria..."
  if ! grep -qi "Developer\|Engineer" "$file" || ! grep -qi "craftsmanship\|craftsman" "$file" || ! grep -qi "Red-Green-Refactor" "$file"; then
    echo "  FAIL: Developer role does not specify software craftsmanship & strict Red-Green-Refactor in $file"
    return 1
  fi
  if ! grep -qi "defensive" "$file" || ! grep -qi "deterministic" "$file"; then
    echo "  FAIL: Developer role does not specify defensive & deterministic coding standards in $file"
    return 1
  fi

  # 7. Tech Writer Role: Senior Staff Technical Writer & Knowledge Architect
  echo "  Checking Technical Writer Role top-tier criteria..."
  if ! grep -qi "Technical Writer\|Knowledge Architect" "$file" || ! grep -qi "runbook\|caveat" "$file"; then
    echo "  FAIL: Technical Writer role does not specify operational runbooks & caveats in $file"
    return 1
  fi

  echo "  PASS: All 7 top-tier industry role contracts verified for $file"
  return 0
}

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

PASS_COUNT=0
FAIL_COUNT=0

if check_top_tier_role_contracts "$TARGET_SOURCE"; then
  PASS_COUNT=$((PASS_COUNT + 1))
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if [ -f "$TARGET_CURSOR" ]; then
  if check_top_tier_role_contracts "$TARGET_CURSOR"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ -f "$TARGET_CODEX" ]; then
  if check_top_tier_role_contracts "$TARGET_CODEX"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed top-tier role contract verification."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT checked files passed top-tier role contract verification."
exit 0
