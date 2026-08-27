#!/usr/bin/env bash
set -euo pipefail

check_deep_review_contract() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating deep review & senior role contracts in: $file"

  # 1. Senior & Expert Roles
  echo "  Checking Senior Roster..."
  if ! grep -qi "Staff/Principal PM" "$file" && ! grep -qi "Principal PM" "$file"; then
    echo "  FAIL: Senior PM role not found in $file"
    return 1
  fi
  if ! grep -qi "Distinguished AI" "$file" && ! grep -qi "Cognitive Architect" "$file"; then
    echo "  FAIL: Distinguished AI Expert / Cognitive Architect role not found in $file"
    return 1
  fi
  if ! grep -qi "Principal Engineer" "$file" && ! grep -qi "Chief Reviewer" "$file"; then
    echo "  FAIL: Principal Engineer / Chief Reviewer role not found in $file"
    return 1
  fi
  if ! grep -qi "Principal Systems Architect" "$file" && ! grep -qi "Systems Architect" "$file"; then
    echo "  FAIL: Principal Systems Architect role not found in $file"
    return 1
  fi
  if ! grep -qi "Senior Principal SDET" "$file" && ! grep -qi "Chaos Gatekeeper" "$file"; then
    echo "  FAIL: Senior Principal SDET / Chaos Gatekeeper role not found in $file"
    return 1
  fi
  if ! grep -qi "Staff Systems Developer" "$file" && ! grep -qi "Staff Developer" "$file"; then
    echo "  FAIL: Staff Systems Developer role not found in $file"
    return 1
  fi

  # 2. Deeper Architecture & Scalability / Parallelism in Phase 2
  echo "  Checking Architecture, Scalability & Parallelism Review in Phase 2..."
  if ! grep -qi "Scalability" "$file"; then
    echo "  FAIL: Scalability criteria not found in $file"
    return 1
  fi
  if ! grep -qi "Parallel" "$file" && ! grep -qi "Concurrency" "$file"; then
    echo "  FAIL: Concurrency/Parallelism criteria not found in $file"
    return 1
  fi
  if ! grep -qi "Robustness" "$file" && ! grep -qi "Graceful Degradation" "$file"; then
    echo "  FAIL: Robustness / Graceful degradation criteria not found in $file"
    return 1
  fi

  # 3. Line-Level Code Review Checklist in Phase 3
  echo "  Checking Line-Level Code Review Checklist in Phase 3..."
  if ! grep -qi "Boundary" "$file" || ! grep -qi "off-by-one" "$file"; then
    echo "  FAIL: Boundary / off-by-one review criteria not found in $file"
    return 1
  fi
  if ! grep -qi "Error Handling" "$file" || ! grep -qi "swallowed" "$file"; then
    echo "  FAIL: Error handling / swallowed error criteria not found in $file"
    return 1
  fi
  if ! grep -qi "String" "$file" || ! grep -qi "injection" "$file"; then
    echo "  FAIL: String / stream / injection safety criteria not found in $file"
    return 1
  fi
  if ! grep -qi "Resource" "$file" || ! grep -qi "leak" "$file"; then
    echo "  FAIL: Resource / memory leak safety criteria not found in $file"
    return 1
  fi
  if ! grep -qi "Complexity" "$file" && ! grep -qi "Algorithmic" "$file"; then
    echo "  FAIL: Algorithmic efficiency / complexity criteria not found in $file"
    return 1
  fi

  echo "  PASS: All deep review contracts verified for $file"
  return 0
}

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_DEPLOYED="$HOME/.cursor/skills/tdd-team/SKILL.md"

PASS_COUNT=0
FAIL_COUNT=0

if check_deep_review_contract "$TARGET_SOURCE"; then
  PASS_COUNT=$((PASS_COUNT + 1))
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if [ -f "$TARGET_DEPLOYED" ]; then
  if check_deep_review_contract "$TARGET_DEPLOYED"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed contract verification."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT files passed deep review contract verification."
exit 0
