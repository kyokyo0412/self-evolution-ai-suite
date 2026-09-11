#!/bin/bash
set -euo pipefail

SKILL_FILE=".ai-suite/layer3-registry/core/loop-work.md"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Error: $SKILL_FILE not found."
  exit 1
fi

echo "Validating loop-work.md for enhancements..."

# 1. Check for "FULL original goal" / "Do not split"
if ! grep -qiE "full.*original.*goal|do not split.*goal" "$SKILL_FILE"; then
  echo "RED: Missing directive to attempt the FULL original goal and not split it."
  exit 1
fi

# 2. Check for "ORIGINAL input task goal" evaluation
if ! grep -qiE "evaluate.*against.*original.*goal|validate.*against.*original.*goal" "$SKILL_FILE"; then
  echo "RED: Missing directive to evaluate against the ORIGINAL input task goal."
  exit 1
fi

# 3. Check for returning to loop-work Execution Protocol after target skill
if ! grep -qiE "return to.*loop-work.*protocol|after.*target skill.*completes" "$SKILL_FILE"; then
  echo "RED: Missing directive to return to loop-work protocol after target skill completes."
  exit 1
fi

# 4. Check for goal of task X as the goal of each iteration
if ! grep -qiE "goal of task.*goal of each iteration|goal of each iteration.*goal of task|goal of every iteration" "$SKILL_FILE"; then
  echo "RED: Missing directive that the goal of task X is the goal of each iteration."
  exit 1
fi

# 5. Check for iterative state reassessment and customized plan
if ! grep -qiE "reassess.*(current state|state).*goal" "$SKILL_FILE"; then
  echo "RED: Missing state reassessment requirement in each iteration."
  exit 1
fi

if ! grep -qiE "customiz(ing|ed)?.*(new )?plan|custom plan" "$SKILL_FILE"; then
  echo "RED: Missing customized plan requirement in each iteration."
  exit 1
fi

# 6. Check for progressive improvement & running task X again
if ! grep -qiE "run.*task.*again|better achieve the goal|progressive.*(improvement|hardening|refinement|convergence)" "$SKILL_FILE"; then
  echo "RED: Missing directive to re-run task and progressively achieve the goal with higher quality."
  exit 1
fi

# 7. Check for structured .loop_state.md logging fields (goal, what, why, how, special notes)
LOG_FIELDS=("goal" "what" "why" "how" "special notes")
for field in "${LOG_FIELDS[@]}"; do
  if ! grep -qiE "$field" "$SKILL_FILE"; then
    echo "RED: Missing required .loop_state.md field '$field'."
    exit 1
  fi
done

# 8. Check for high-quality achievement of the goal after all iterations
if ! grep -qiE "high-quality achievement of the goal|high-quality.*achievement" "$SKILL_FILE"; then
  echo "RED: Missing requirement that all iterations culminate in high-quality achievement of the goal."
  exit 1
fi

echo "GREEN: All requirements are met in loop-work.md."
exit 0
