#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-principal-coding-review-eut.sh
# End-to-End User Acceptance Test for Principal Coding Engineer Adversarial AI-Review & Pre-Emptive Fix Gate.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== [SDET EUT Gate] Running EUT for Principal Coding Engineer & Adversarial AI-Review Gate ==="

TARGET_SOURCE="$REPO_ROOT/.ai-suite/layer3-registry/core/tdd-team.md"
CODE_QUALITY_DIRECTIVE="$REPO_ROOT/.ai-suite/layer3-registry/directives/code-quality.md"
AGENT_DIRECTIVES="$REPO_ROOT/.ai-suite/layer3-registry/directives/agent-directives.md"

# 1. Check core tdd-team.md contracts
if ! bash "$SCRIPT_DIR/test-tdd-team-principal-coding-review-contracts.sh"; then
  echo "FAIL: Contract verification failed during EUT."
  exit 1
fi

# 2. Check code-quality.md for Pre-Review Zero-Defect Standards
echo "Checking code-quality.md for Pre-Review Zero-Defect Standards..."
if ! grep -qi "Pre-Review Zero-Defect" "$CODE_QUALITY_DIRECTIVE" && ! grep -qi "Anti-AI-Review" "$CODE_QUALITY_DIRECTIVE"; then
  echo "FAIL: code-quality.md does not mandate Pre-Review Zero-Defect Standards."
  exit 1
fi

# 3. Check agent-directives.md for Principal Coding Engineer review requirement
echo "Checking agent-directives.md for Principal Coding Engineer review requirement..."
if ! grep -qi "Principal Coding Engineer" "$AGENT_DIRECTIVES" && ! grep -qi "Adversarial" "$AGENT_DIRECTIVES"; then
  echo "FAIL: agent-directives.md does not mandate Principal Coding Engineer / Adversarial review."
  exit 1
fi

# 4. Verify no whitespace-only blank lines in newly introduced files
echo "Checking whitespace cleanliness in test and feature files..."
for f in "$SCRIPT_DIR/tdd-team-principal-coding-review.feature" \
         "$SCRIPT_DIR/tdd-team-principal-coding-review-contracts.md" \
         "$SCRIPT_DIR/test-tdd-team-principal-coding-review-contracts.sh"; do
  if [[ -f "$f" ]]; then
    if grep -n -E '^[[:space:]]+$' "$f" >/dev/null; then
      echo "FAIL: File $f contains whitespace-only blank lines."
      exit 1
    fi
  fi
done

echo "PASS: All Principal Coding Engineer EUT criteria passed successfully!"
exit 0
