#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-zero-defect-codegen-contracts.sh
# Validates Zero-Defect Code Generation contracts in tdd-team skill files:
# 1. Core Directives 13 & 14 (Design-by-Contract formal invariants, non-vacuous assertions).
# 2. Negative Constraints (forbidding code without DbC invariants, forbidding vacuous assertions).
# 3. Role duties in Team Roster (Architect, Developer, SDET, Reviewer).
# 4. Phase 1 Formal Boundary Value Analysis (BVA) Extrema Matrix.
# 5. Phase 2 Dimension 9 (Formal Invariants & Design-by-Contract).
# 6. Phase 3 Non-Vacuous Red Proof & Strict Compiler/Static Analysis Gate.
# 7. Phase 3.5 & 3.6 14-Dimension Verification Checklist & Zero-Defect Audit Certification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

check_file_contracts() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating Zero-Defect Code Generation contracts in: $file"

  # 1. Core Directive 13 & 14
  echo "  Checking Core Directives 13 and 14..."
  if ! grep -qi "Zero-Defect Code Generation & Formal Invariants" "$file"; then
    echo "  FAIL: Core Directive 13 missing in $file"
    return 1
  fi
  if ! grep -qi "Design by Contract" "$file" || ! grep -qi "preconditions.*requires" "$file"; then
    echo "  FAIL: Design by Contract with preconditions missing in $file"
    return 1
  fi
  if ! grep -qi "Non-Vacuous Assertions & Mutation Resistance" "$file"; then
    echo "  FAIL: Core Directive 14 missing in $file"
    return 1
  fi

  # 2. Negative Constraints
  echo "  Checking Negative Constraints for DbC and Compiler Warnings..."
  if ! grep -qi "Do not generate code without Design-by-Contract" "$file"; then
    echo "  FAIL: Negative constraint against generating code without DbC missing in $file"
    return 1
  fi
  if ! grep -qi "Do not allow vacuous test assertions or compiler warnings" "$file"; then
    echo "  FAIL: Negative constraint against vacuous assertions / compiler warnings missing in $file"
    return 1
  fi

  # 3. Roster Duties for Zero-Defect Code Generation
  echo "  Checking Roster duties for zero-defect code generation..."
  if ! grep -qi "Design-by-Contract (DbC) invariants" "$file" && ! grep -qi "DbC invariants" "$file"; then
    echo "  FAIL: Architect DbC invariants duty missing in $file"
    return 1
  fi
  if ! grep -qi "Strict Compiler & Static Analysis Gate" "$file"; then
    echo "  FAIL: Developer Strict Compiler Gate duty missing in $file"
    return 1
  fi
  if ! grep -qi "non-vacuous assertion proof" "$file"; then
    echo "  FAIL: SDET non-vacuous assertion proof duty missing in $file"
    return 1
  fi
  if ! grep -qi "Vetoes any deliverable lacking formal Design-by-Contract" "$file"; then
    echo "  FAIL: Chief Reviewer DbC veto duty missing in $file"
    return 1
  fi

  # 4. Phase 1 BVA Extrema Matrix
  echo "  Checking Phase 1 BVA Extrema Matrix..."
  if ! grep -qi "Formal Boundary Value Analysis (BVA) Extrema Matrix" "$file"; then
    echo "  FAIL: Phase 1 BVA Extrema Matrix missing in $file"
    return 1
  fi

  # 5. Phase 2 Dimension 9
  echo "  Checking Phase 2 Dimension 9 (Formal Invariants & DbC)..."
  if ! grep -qi "Formal Invariants & Design-by-Contract (DbC)" "$file"; then
    echo "  FAIL: Phase 2 Dimension 9 missing in $file"
    return 1
  fi

  # 6. Phase 3 Implementation & Strict Compiler Gate
  echo "  Checking Phase 3 Implementation & Compiler Gate..."
  if ! grep -qi "Non-Vacuous Assertion Verification" "$file"; then
    echo "  FAIL: Phase 3 Non-Vacuous Assertion Verification missing in $file"
    return 1
  fi
  if ! grep -qi "Strict Compiler & Static Analysis Gate" "$file"; then
    echo "  FAIL: Phase 3 Strict Compiler Gate missing in $file"
    return 1
  fi

  # 7. Phase 3.5 & 3.6 14-Dimension Checklist & Certification
  echo "  Checking 14-Dimension Verification Checklist & Audit Certification..."
  if ! grep -qi "14 Dimensions" "$file"; then
    echo "  FAIL: 14-Dimension checklist reference missing in $file"
    return 1
  fi
  if ! grep -qi "Design-by-Contract & Formal Invariant Enforcement" "$file"; then
    echo "  FAIL: Dimension 13 missing in $file"
    return 1
  fi
  if ! grep -qi "Strict Compiler/Linter Zero-Warning & Non-Vacuous Mutation Gate" "$file"; then
    echo "  FAIL: Dimension 14 missing in $file"
    return 1
  fi
  if ! grep -qi "Zero-Defect Audit Certification.*14 checklist dimensions" "$file"; then
    echo "  FAIL: Zero-Defect Audit Certification for 14 dimensions missing in $file"
    return 1
  fi

  echo "  PASS: Zero-Defect Code Generation contracts verified for $file"
  return 0
}

TARGET_SOURCE="${1:-$REPO_ROOT/.ai-suite/layer3-registry/core/tdd-team.md}"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

PASS_COUNT=0
FAIL_COUNT=0

if [[ $# -gt 0 ]]; then
  if check_file_contracts "$1"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
else
  for target in "$TARGET_SOURCE" "$TARGET_CURSOR" "$TARGET_CODEX"; do
    if [[ -f "$target" ]]; then
      if check_file_contracts "$target"; then
        PASS_COUNT=$((PASS_COUNT + 1))
      else
        FAIL_COUNT=$((FAIL_COUNT + 1))
      fi
    fi
  done
fi

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed Zero-Defect Code Generation contract checks."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT files passed Zero-Defect Code Generation contract checks."
exit 0
