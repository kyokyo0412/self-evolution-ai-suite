#!/bin/bash
set -euo pipefail

SKILL_FILE=".ai-suite/layer3-registry/core/loop-work.md"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Error: $SKILL_FILE not found."
  exit 1
fi

echo "Running Deep Validation for loop-work.md..."

# 1. Frontmatter check
if ! grep -q "^name: loop-work" "$SKILL_FILE"; then
  echo "RED: Missing frontmatter 'name: loop-work'"
  exit 1
fi

# 2. Identical Task Target Invariant check
if ! grep -qiE "same.*task.*target|identical.*task.*target" "$SKILL_FILE"; then
  echo "RED: Missing Identical Task Target Invariant"
  exit 1
fi

# 3. Spatial Partitioning Anti-Pattern check
if ! grep -qiE "Spatial Partitioning|Target Chunking" "$SKILL_FILE"; then
  echo "RED: Missing Spatial Partitioning / Target Chunking anti-pattern definition"
  exit 1
fi

# 4. Dimensional Partitioning Anti-Pattern check
if ! grep -qiE "Dimensional Partitioning|Aspect Splitting" "$SKILL_FILE"; then
  echo "RED: Missing Dimensional Partitioning / Aspect Splitting anti-pattern definition"
  exit 1
fi

# 5. Phasing / Workflow Partitioning Anti-Pattern check
if ! grep -qiE "Phasing.*Partitioning|Workflow.*Partitioning|spread.*workflow.*phases" "$SKILL_FILE"; then
  echo "RED: Missing Phasing / Workflow Partitioning anti-pattern definition"
  exit 1
fi

# 6. In-Iteration Bug Fixing & Cumulative Hardening
if ! grep -qiE "fix.*within.*iteration|fix.*in.*iteration" "$SKILL_FILE"; then
  echo "RED: Missing in-iteration bug fixing directive"
  exit 1
fi

if ! grep -qiE "cumulative.*hardening|re-review.*entire|re-verify.*full" "$SKILL_FILE"; then
  echo "RED: Missing cumulative hardening / full re-review directive"
  exit 1
fi

# 7. Goal Alignment & Iterative Reassessment
if ! grep -qiE "goal of task.*goal of each iteration|goal of each iteration.*goal of task|goal of every iteration" "$SKILL_FILE"; then
  echo "RED: Missing Goal Alignment across iterations"
  exit 1
fi

if ! grep -qiE "reassess.*(current state|state).*goal" "$SKILL_FILE"; then
  echo "RED: Missing State Reassessment per iteration"
  exit 1
fi

if ! grep -qiE "customiz(ing|ed)?.*(new )?plan|custom plan" "$SKILL_FILE"; then
  echo "RED: Missing Customized Plan formulation per iteration"
  exit 1
fi

# 8. Cognitive Self-Evaluation Questions in LLM Validation
if ! grep -qiE "Cognitive Self-Evaluation|self-check|self-evaluation" "$SKILL_FILE"; then
  echo "RED: Missing Cognitive Self-Evaluation section in LLM validation"
  exit 1
fi

# 9. State Tracking & Structured .loop_state.md Logging
if ! grep -qiE "\.loop_state\.md" "$SKILL_FILE"; then
  echo "RED: Missing .loop_state.md specification"
  exit 1
fi

REQUIRED_LOG_ITEMS=("goal" "what" "why" "how" "special notes")
for item in "${REQUIRED_LOG_ITEMS[@]}"; do
  if ! grep -qiE "$item" "$SKILL_FILE"; then
    echo "RED: Missing required .loop_state.md log item '$item'"
    exit 1
  fi
done

if ! grep -qiE "AGENT_LOOP_WAKE_loop_work" "$SKILL_FILE"; then
  echo "RED: Missing AGENT_LOOP_WAKE_loop_work sentinel"
  exit 1
fi

# 10. Mandatory Full Iteration Execution (No Early Exit Loophole)
if ! grep -qiE "strict(ly)?.*mandat(e|ory).*iteration|execute.*all.*N.*iterations|no.*early.*exit|forbidden.*from.*early.*exit" "$SKILL_FILE"; then
  echo "RED: Missing mandatory full iteration execution without early exit."
  exit 1
fi

if grep -qiE "or until verified 100% defect-free convergence is achieved" "$SKILL_FILE"; then
  echo "RED: Premature convergence early-exit loophole 'or until verified 100% defect-free convergence is achieved' is still present."
  exit 1
fi

# 11. Progressive Hardening Framework
if ! grep -qi "Progressive Hardening Framework" "$SKILL_FILE"; then
  echo "RED: Missing Progressive Hardening Framework section."
  exit 1
fi

# 12. High-Quality Completion
if ! grep -qiE "high-quality achievement of the goal|high-quality.*achievement" "$SKILL_FILE"; then
  echo "RED: Missing high-quality goal achievement requirement"
  exit 1
fi

# 13. Isolation Principle & Self-Evolution Preservation
if ! grep -qiE "isolation principle" "$SKILL_FILE"; then
  echo "RED: Missing isolation principle preservation"
  exit 1
fi

if ! grep -qiE "self-evolution" "$SKILL_FILE"; then
  echo "RED: Missing self-evolution preservation"
  exit 1
fi

echo "GREEN: All deep validation checks passed successfully for loop-work.md."
exit 0
