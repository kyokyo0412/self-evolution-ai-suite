#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-principal-coding-review-contracts.sh
# Validates Principal Coding Engineer and Adversarial AI-Review contracts across tdd-team skill files.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

check_file_contracts() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating Principal Coding Engineer & Adversarial AI-Review contracts in: $file"

  # 1. Principal Coding Engineer role in roster
  echo "  Checking Principal Coding Engineer / Chief Reviewer role in roster..."
  if ! grep -qi "Principal Coding Engineer" "$file" && ! grep -qi "Remediation Master" "$file"; then
    echo "  FAIL: Principal Coding Engineer role not found in $file"
    return 1
  fi

  # 2. Adversarial AI-Review Simulation in Phase 3
  echo "  Checking Adversarial AI-Review Simulation in Phase 3..."
  if ! grep -qi "Adversarial" "$file" || ! grep -qi "AI-Review" "$file"; then
    echo "  FAIL: Adversarial AI-Review Simulation not found in $file"
    return 1
  fi

  # 3. 10-Dimension Anti-AI-Review Verification Checklist
  echo "  Checking 10-Dimension Anti-AI-Review Verification Checklist..."
  if ! grep -qi "Boundary & Null/Nil Safety" "$file" && ! grep -qi "Boundary & Nil Safety" "$file"; then
    echo "  FAIL: Boundary & Null/Nil Safety criteria missing in $file"
    return 1
  fi
  if ! grep -qi "Deterministic Error Handling" "$file" && ! grep -qi "swallowed" "$file"; then
    echo "  FAIL: Error handling and swallowed error criteria missing in $file"
    return 1
  fi
  if ! grep -qi "Strict Resource Lifecycle" "$file" && ! grep -qi "Resource & Memory Safety" "$file"; then
    echo "  FAIL: Resource lifecycle and leak prevention criteria missing in $file"
    return 1
  fi
  if ! grep -qi "Concurrency" "$file" || ! grep -qi "Race" "$file"; then
    echo "  FAIL: Concurrency and race safety criteria missing in $file"
    return 1
  fi
  if ! grep -qi "Security" "$file" || ! grep -qi "Injection" "$file"; then
    echo "  FAIL: Security and injection prevention criteria missing in $file"
    return 1
  fi
  if ! grep -qi "Algorithmic" "$file" && ! grep -qi "Complexity" "$file"; then
    echo "  FAIL: Algorithmic complexity criteria missing in $file"
    return 1
  fi
  if ! grep -qi "Code Formatting" "$file" && ! grep -qi "Gitreview Red-Flag" "$file"; then
    echo "  FAIL: Formatting and gitreview red-flag criteria missing in $file"
    return 1
  fi
  if ! grep -qi "Anti-Hardcoding" "$file" || ! grep -qi "Dynamic" "$file"; then
    echo "  FAIL: Anti-hardcoding and dynamic assertions criteria missing in $file"
    return 1
  fi

  # 4. Autonomous Pre-Emptive Fix & Remediation Loop
  echo "  Checking Autonomous Pre-Emptive Fix & Remediation..."
  if ! grep -qi "Pre-Emptive Fix" "$file" && ! grep -qi "Autonomous Pre-Emptive" "$file"; then
    echo "  FAIL: Autonomous Pre-Emptive Fix step missing in $file"
    return 1
  fi
  if ! grep -qi "Zero-Defect Audit Certification" "$file" && ! grep -qi "Zero-Defect" "$file"; then
    echo "  FAIL: Zero-Defect Audit Certification missing in $file"
    return 1
  fi

  # 5. Negative Constraint
  echo "  Checking Negative Constraint against bypassing Principal Coding Engineer gate..."
  if ! grep -qi "Do not bypass the Principal Coding Engineer" "$file" && ! grep -qi "Principal Coding Engineer Adversarial" "$file"; then
    echo "  FAIL: Negative constraint against bypassing Principal Coding Engineer gate missing in $file"
    return 1
  fi

  echo "  PASS: Principal Coding Engineer & Adversarial AI-Review contracts verified for $file"
  return 0
}

TARGET_SOURCE="$REPO_ROOT/.ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

PASS_COUNT=0
FAIL_COUNT=0

for target in "$TARGET_SOURCE" "$TARGET_CURSOR" "$TARGET_CODEX"; do
  if [[ -f "$target" ]]; then
    if check_file_contracts "$target"; then
      PASS_COUNT=$((PASS_COUNT + 1))
    else
      FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
  fi
done

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed Principal Coding Engineer contract checks."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT files passed Principal Coding Engineer contract checks."
exit 0
