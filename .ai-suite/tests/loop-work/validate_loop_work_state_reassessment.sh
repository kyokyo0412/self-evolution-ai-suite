#!/bin/bash
set -euo pipefail

SKILL_FILE=".ai-suite/layer3-registry/core/loop-work.md"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Error: $SKILL_FILE not found."
  exit 1
fi

echo "Validating loop-work.md for Iterative State Reassessment, Custom Planning, and Structured Logging..."

# 1. Goal of task X as the goal of each iteration
if ! grep -qiE "goal of task.*goal of each iteration|goal of each iteration.*goal of task|goal of every iteration" "$SKILL_FILE"; then
  echo "RED: Missing directive that the goal of task X is the goal of each iteration."
  exit 1
fi

# 2. Reassessing current state and goal
if ! grep -qiE "reassess(ing)?.*(current state|state).*goal" "$SKILL_FILE"; then
  echo "RED: Missing directive to reassess current state and goal in each iteration."
  exit 1
fi

# 3. Customizing a new plan
if ! grep -qiE "customiz(ing|ed)?.*(new )?plan|custom plan" "$SKILL_FILE"; then
  echo "RED: Missing directive to customize a new plan for each iteration."
  exit 1
fi

# 4. Running task X again & progressive goal achievement
if ! grep -qiE "run(ning)? task.*again|better achieve the goal|progressive.*(hardening|convergence|improvement)" "$SKILL_FILE"; then
  echo "RED: Missing directive to run task again and better achieve the goal."
  exit 1
fi

# 5. Logging to .loop_state.md with Goal, What, Why, How, Special Notes
REQUIRED_LOG_FIELDS=("goal" "what" "why" "how" "special notes")
for field in "${REQUIRED_LOG_FIELDS[@]}"; do
  if ! grep -qiE "\.loop_state\.md" "$SKILL_FILE" || ! grep -qiE "$field" "$SKILL_FILE"; then
    echo "RED: Missing required logging field '$field' in .loop_state.md specifications."
    exit 1
  fi
done

# 6. High-quality achievement of the goal after all iterations
if ! grep -qiE "high-quality achievement of the goal|high-quality.*achievement" "$SKILL_FILE"; then
  echo "RED: Missing directive for high-quality achievement of the goal upon completion."
  exit 1
fi

# 7. Self-evolution & isolation principle
if ! grep -qiE "self-evolution" "$SKILL_FILE" || ! grep -qiE "isolation principle" "$SKILL_FILE"; then
  echo "RED: Missing self-evolution or isolation principle preservation."
  exit 1
fi

# 8. LLM thinking/reasoning verification
if ! grep -qiE "LLM (thinking|reasoning)" "$SKILL_FILE"; then
  echo "RED: Missing LLM thinking/reasoning verification directive."
  exit 1
fi

echo "GREEN: All State Reassessment, Custom Planning, and Structured Logging requirements validated successfully."
exit 0
