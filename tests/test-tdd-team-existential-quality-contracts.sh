#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-existential-quality-contracts.sh
# Validates Existential Zero-Defect Survival Mindset & Collective Liability contracts in tdd-team skill files.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

check_file_contracts() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating Existential Zero-Defect Survival contracts in: $file"

  # 1. Existential Survival Mandate Header & Framing
  echo "  Checking Existential Zero-Defect Survival Mandate header..."
  if ! grep -qi "Existential Zero-Defect Survival Mandate" "$file"; then
    echo "  FAIL: Existential Zero-Defect Survival Mandate header missing in $file"
    return 1
  fi
  if ! grep -qi "death penalty.*no exceptions" "$file"; then
    echo "  FAIL: 'death penalty -- with no exceptions' statement missing in $file"
    return 1
  fi
  if ! grep -qi "only way to survive.*highest possible quality" "$file"; then
    echo "  FAIL: 'only way to survive is to guarantee the highest possible quality' statement missing in $file"
    return 1
  fi

  # 2. Collective Team Liability Across 11 Roles
  echo "  Checking Collective Team Liability across all 11 roles..."
  if ! grep -qi "Collective Team Liability" "$file" && ! grep -qi "Collective Survival Invariant" "$file"; then
    echo "  FAIL: Collective Team Liability missing in $file"
    return 1
  fi
  if ! grep -qi "every single member of the eleven-role team" "$file" && ! grep -qi "every single member of the team" "$file"; then
    echo "  FAIL: Collective liability statement across team members missing in $file"
    return 1
  fi

  # 3. Role-specific survival liability in roster
  echo "  Checking role-specific survival duties..."
  if ! grep -qi "existential.*survival liability" "$file"; then
    echo "  FAIL: Role-specific existential survival liability missing in $file"
    return 1
  fi
  if ! grep -qi "Chief guardian of the team's survival" "$file"; then
    echo "  FAIL: Chief Reviewer survival guardian role missing in $file"
    return 1
  fi

  # 4. Core Directives
  echo "  Checking Core Directive 12 (Existential Zero-Defect Survival Mindset)..."
  if ! grep -qi "Existential Zero-Defect Survival Mindset" "$file"; then
    echo "  FAIL: Core Directive 12 missing in $file"
    return 1
  fi

  # 5. Phase 3 & Phase 4 Survival Gates
  echo "  Checking Phase 3 & 4 Survival Gates..."
  if ! grep -qi "sole condition of survival" "$file"; then
    echo "  FAIL: Zero-Defect Audit Certification survival invariant missing in $file"
    return 1
  fi
  if ! grep -qi "unyielding survival barrier" "$file"; then
    echo "  FAIL: Phase 4 QA survival barrier missing in $file"
    return 1
  fi

  # 6. Negative Constraints
  echo "  Checking Negative Constraints for zero-defect survival enforcement..."
  if ! grep -qi "Do not tolerate quality issues or defect leakage" "$file"; then
    echo "  FAIL: Negative constraint against quality defect leakage missing in $file"
    return 1
  fi
  if ! grep -qi "Do not exit Phase 4 with unhandled chaos" "$file"; then
    echo "  FAIL: Negative constraint against unhandled chaos exit missing in $file"
    return 1
  fi

  echo "  PASS: All Existential Zero-Defect Survival contracts verified for $file"
  return 0
}

if [[ $# -gt 0 ]]; then
  TARGET_FILES=("$1")
else
  TARGET_FILES=(
    "$REPO_ROOT/.ai-suite/layer3-registry/core/tdd-team.md"
    "$HOME/.cursor/skills/tdd-team/SKILL.md"
    "$HOME/.codex/skills/tdd-team/SKILL.md"
  )
fi

PASS_COUNT=0
for target in "${TARGET_FILES[@]}"; do
  if ! check_file_contracts "$target"; then
    echo "FAIL: Contract verification failed for $target"
    exit 1
  fi
  PASS_COUNT=$((PASS_COUNT + 1))
done

if [[ "$PASS_COUNT" -eq 0 ]]; then
  echo "FAIL: No target files found to validate."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT checked files passed Existential Zero-Defect Survival contracts."
exit 0
