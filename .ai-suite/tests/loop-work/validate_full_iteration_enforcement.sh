#!/bin/bash
set -euo pipefail

SKILL_FILE=".ai-suite/layer3-registry/core/loop-work.md"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Error: $SKILL_FILE not found."
  exit 1
fi

echo "Validating loop-work.md for Full Iteration Enforcement & Progressive Hardening..."

# 1. Check for Strict Mandatory Iteration Count (No Premature Early Exit)
if ! grep -qiE "strict(ly)?.*mandat(e|ory).*iteration|execute.*all.*N.*iterations|no.*early.*exit|forbidden.*from.*early.*exit" "$SKILL_FILE"; then
  echo "RED: Missing strict mandatory iteration count / prohibition against premature early exit."
  exit 1
fi

# Ensure early-exit loophole has been removed or strictly constrained
if grep -qiE "or until verified 100% defect-free convergence is achieved" "$SKILL_FILE"; then
  echo "RED: Premature convergence early-exit loophole 'or until verified 100% defect-free convergence is achieved' is still present."
  exit 1
fi

# 2. Check for Autonomous Background Continuation Protocol with notify_on_output & block_until_ms: 0
if ! grep -qiE "AGENT_LOOP_WAKE_loop_work" "$SKILL_FILE"; then
  echo "RED: Missing AGENT_LOOP_WAKE_loop_work sentinel."
  exit 1
fi

if ! grep -qiE "notify_on_output" "$SKILL_FILE" || ! grep -qiE "block_until_ms: 0" "$SKILL_FILE"; then
  echo "RED: Missing explicit notify_on_output or block_until_ms: 0 background execution directives."
  exit 1
fi

# 3. Check for Progressive Deepening & Hardening Framework
REQUIRED_HARDENING_DIMENSIONS=(
  "concurrency"
  "race"
  "fuzz"
  "memory"
  "mutation"
)

for dim in "${REQUIRED_HARDENING_DIMENSIONS[@]}"; do
  if ! grep -qiE "$dim" "$SKILL_FILE"; then
    echo "RED: Missing progressive hardening dimension '$dim'."
    exit 1
  fi
done

# 3b. Check for Continuous Multi-Dimensional Envelope and Non-Partitioned Hardening
if ! grep -qiE "Continuous Multi-Dimensional Hardening Envelope|multi-dimensional.*envelope" "$SKILL_FILE"; then
  echo "RED: Missing Continuous Multi-Dimensional Hardening Envelope specification."
  exit 1
fi

if ! grep -qiE "cumulative.*(iterative )?depth|orders of emergence" "$SKILL_FILE"; then
  echo "RED: Missing cumulative iterative depth / orders of emergence specification."
  exit 1
fi

# 4. Check for Interactive Workflow Isolation (no summary or AskQuestion until N iterations complete)
if ! grep -qiE "main task is the entire loop|do not trigger state 2 or state 3 prematurely|all N iterations are completely finished" "$SKILL_FILE"; then
  echo "RED: Missing strict isolation constraint between loop-work and interactive-workflow."
  exit 1
fi

# 5. Check for Structured Logging in .loop_state.md
if ! grep -qiE "\.loop_state\.md" "$SKILL_FILE"; then
  echo "RED: Missing .loop_state.md state logging requirement."
  exit 1
fi

echo "GREEN: All Full Iteration Enforcement requirements validated successfully."
exit 0
