#!/bin/bash
set -euo pipefail

SKILL_FILE=".ai-suite/layer3-registry/core/loop-work.md"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Error: $SKILL_FILE not found"
  exit 1
fi

echo "Validating loop-work.md architectural contract..."

# 1. Frontmatter check
if ! grep -q "^name: loop-work" "$SKILL_FILE"; then
  echo "Error: Missing name: loop-work"
  exit 1
fi

if ! grep -q "triggers:" "$SKILL_FILE"; then
  echo "Error: Missing triggers:"
  exit 1
fi

# 2. Key architectural sections
REQUIRED_SECTIONS=(
  "Core Directives"
  "Identical Full Task Iteration Invariant"
  "Integration with Interactive Workflow & Step Action Visibility"
  "State Tracking"
  "Continuation Protocol"
  "Progressive Hardening Framework"
  "Execution Protocol"
  "Negative Constraints"
)

for sec in "${REQUIRED_SECTIONS[@]}"; do
  if ! grep -qi "$sec" "$SKILL_FILE"; then
    echo "RED: Missing required architectural section '$sec' in $SKILL_FILE"
    exit 1
  fi
done

# 3. State Tracking and Continuation requirements
if ! grep -qi "AGENT_LOOP_WAKE_loop_work" "$SKILL_FILE"; then
  echo "RED: Missing AGENT_LOOP_WAKE_loop_work sentinel specification"
  exit 1
fi

if ! grep -qi "\.loop_state\.md" "$SKILL_FILE"; then
  echo "RED: Missing .loop_state.md state tracking file specification"
  exit 1
fi

if ! grep -qi "notify_on_output" "$SKILL_FILE" || ! grep -qi "block_until_ms: 0" "$SKILL_FILE"; then
  echo "RED: Missing notify_on_output or block_until_ms: 0 background execution specification"
  exit 1
fi

# 4. Anti-partitioning and Goal Invariance contract checks
if ! grep -qi "Spatial Partitioning" "$SKILL_FILE"; then
  echo "RED: Missing explicit Spatial Partitioning architectural constraint"
  exit 1
fi

if ! grep -qi "Dimensional Partitioning" "$SKILL_FILE"; then
  echo "RED: Missing explicit Dimensional Partitioning architectural constraint"
  exit 1
fi

# 5. Mandatory Full Iteration Count & Anti-Early Exit Contract
if ! grep -qiE "strict(ly)?.*mandat(e|ory).*iteration|execute.*all.*N.*iterations|no.*early.*exit|forbidden.*from.*early.*exit" "$SKILL_FILE"; then
  echo "RED: Missing mandatory full iteration count / anti-early exit contract"
  exit 1
fi

# 6. Goal Alignment & State Reassessment Contracts
if ! grep -qiE "goal of task.*goal of each iteration|goal of each iteration.*goal of task|goal of every iteration" "$SKILL_FILE"; then
  echo "RED: Missing Goal Alignment contract across iterations"
  exit 1
fi

if ! grep -qiE "reassess(ing)?.*(current state|state).*goal" "$SKILL_FILE"; then
  echo "RED: Missing State Reassessment contract"
  exit 1
fi

if ! grep -qiE "customiz(ing|ed)?.*(new )?plan|custom plan" "$SKILL_FILE"; then
  echo "RED: Missing Customized Plan contract"
  exit 1
fi

# 7. Structured .loop_state.md Schema Check
REQUIRED_SCHEMA_FIELDS=("goal" "what" "why" "how" "special notes")
for field in "${REQUIRED_SCHEMA_FIELDS[@]}"; do
  if ! grep -qiE "$field" "$SKILL_FILE"; then
    echo "RED: Missing required .loop_state.md schema field '$field'"
    exit 1
  fi
done

echo "GREEN: Architectural contract validation passed."
exit 0
