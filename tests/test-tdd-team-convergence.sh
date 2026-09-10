#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-convergence.sh
# Final Order-N Formal Invariance & Zero-Defect Convergence Test Suite

echo "=================================================================="
echo " Starting Final Order-N Formal Convergence & Zero-Defect Proof   "
echo "=================================================================="

SUITE_ROOT="/Users/dc005518/gitsource/dc005518_cursor_evolution"
cd "$SUITE_ROOT"

PASS_COUNT=0
FAIL_COUNT=0

check_step() {
  local desc="$1"
  shift
  echo -n "  [Order-N] $desc ... "
  if "$@" >/dev/null 2>&1; then
    echo "PASS"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    echo "FAIL"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# 1. Order-1 Primary Baseline
check_step "Order-1 Domain SME Contracts" bash tests/test-tdd-team-domain-sme-contracts.sh
check_step "Order-1 Domain SME EUT" bash tests/test-tdd-team-domain-sme-eut.sh

# 2. Order-2 Synergy & Multi-Domain Exemplar
check_step "Order-2 Top-Tier Roster Contracts" bash tests/test-tdd-team-top-tier-roles-contracts.sh
check_step "Order-2 Deep Review Contracts" bash tests/test-tdd-team-deep-review-contracts.sh

# 3. Order-3 Concurrency & Adversarial Chaos
check_step "Order-3 Concurrency & Race Safety" bash tests/test-tdd-team-concurrency-race-contracts.sh
check_step "Order-3 Adversarial Chaos & Fault Injection" bash tests/test-tdd-team-adverse-chaos-contracts.sh

# 4. Order-4 1E-Class Nuclear Safety & Domain Ergonomics
check_step "Order-4 1E-Class Safety & Deterministic Bounds" bash tests/test-tdd-team-resource-safety-contracts.sh
check_step "Order-4 Web/Mobile & Domain Ergonomics Contracts" bash tests/test-tdd-team-web-mobile-ai-contracts.sh
check_step "Order-4 Web/Mobile & Domain Ergonomics EUT" bash tests/test-tdd-team-web-mobile-ai-eut.sh

# 5. Order-5 Mutation Analysis & Developer Runbook
check_step "Order-5 Mutation Analysis (100% Score)" bash tests/test-tdd-team-mutation.sh
check_step "Order-5 Developer Runbook Contracts" bash tests/test-tdd-team-developer-runbook-contracts.sh
check_step "Order-5 Project Documentation Update Rule" bash tests/test-tdd-team-readme.sh

# 6. Triple-Copy Skill Synchronization Invariance
check_skill_sync() {
  local f1=".ai-suite/layer3-registry/core/tdd-team.md"
  local f2="$HOME/.cursor/skills/tdd-team/SKILL.md"
  local f3="$HOME/.codex/skills/tdd-team/SKILL.md"

  cmp -s "$f1" "$f2" || return 1
  cmp -s "$f1" "$f3" || return 1
  return 0
}
check_step "Triple-Copy Skill Synchronization Invariance" check_skill_sync

# 7. ASCII Cleanliness
check_step "Repository ASCII Cleanliness" bash tests/test-ascii-codex-contracts.sh

# 8. Zero Whitespace-only Blank Lines across Modified/New Files
check_whitespace() {
  python3 -c "
import subprocess
out = subprocess.check_output(['git', 'status', '-s'], text=True)
files = [l.strip().split()[-1] for l in out.strip().split('\n') if l.strip()]
for f in files:
    try:
        with open(f, 'r') as fp:
            for line in fp:
                if line.strip() == '' and len(line) > 1:
                    exit(1)
    except Exception:
        pass
exit(0)
"
}
check_step "Zero Whitespace-Only Blank Lines across Modified Files" check_whitespace

# 9. Loop-Work & Interactive Workflow Contracts & EUT
check_step "Loop-Work & Interactive Workflow Contracts" bash tests/test-loop-work-interactive-contracts.sh
check_step "Loop-Work & Interactive Workflow EUT" bash tests/test-loop-work-interactive-eut.sh

# 10. Cursor Adapter Pruning & Zero Stale Artifact Invariance
check_step "Cursor Adapter Pruning Contracts" bash tests/test-cursor-adapter-enable-pruning-contracts.sh

echo "=================================================================="
echo " Formal Convergence Summary: $PASS_COUNT passed, $FAIL_COUNT failed"
echo "=================================================================="

if [ "$FAIL_COUNT" -gt 0 ]; then
  exit 1
fi
exit 0
