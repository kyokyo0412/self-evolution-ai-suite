#!/usr/bin/env bash
set -euo pipefail

echo "Running EUT tests for enhanced tdd-team skill..."

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_DEPLOYED="$HOME/.cursor/skills/tdd-team/SKILL.md"

validate_eut() {
  local file="$1"
  echo "Evaluating EUT criteria on $file..."

  # 1. Roster seniority check
  grep -qi "Staff/Principal PM" "$file"
  grep -qi "Distinguished AI Expert" "$file"
  grep -qi "Fellow/Principal Engineer" "$file"
  grep -qi "Principal Systems Architect" "$file"
  grep -qi "Senior Principal SDET" "$file"
  grep -qi "Staff Systems Developer" "$file"
  grep -qi "Senior Lead Technical Writer" "$file"

  # 2. Phase 1 enhanced product & requirement review
  grep -qi "Product Discovery & Legacy Review" "$file"
  grep -qi "simulated discussion" "$file"

  # 3. Phase 2 deep architecture & scalability review
  grep -qi "Scalability" "$file"
  grep -qi "Parallel" "$file"
  grep -qi "Robustness" "$file"
  grep -qi "Graceful Degradation" "$file"

  # 4. Phase 3 deep line-level code review & mental dry-run
  grep -qi "Mental Dry-Run" "$file"
  grep -qi "Line-Level" "$file" || grep -qi "line-by-line" "$file"
  grep -qi "Boundary" "$file"
  grep -qi "Error Handling" "$file"
  grep -qi "String" "$file"
  grep -qi "Resource" "$file"
  grep -qi "Concurrency" "$file"
  grep -qi "Complexity" "$file" || grep -qi "Algorithmic" "$file"

  # 5. Backward compatibility with existing required constraints
  grep -qi "README.md" "$file"
  grep -qi "Do not skip Role Visibility" "$file"
  grep -qi "review the tasks, rules, and constraint" "$file" || grep -qi "review the tasks, rules and constraint" "$file"
  grep -qi "review the \`*tdd-team\`* skill" "$file"
  grep -qi "git" "$file"

  echo "EUT evaluation passed for $file"
}

validate_eut "$TARGET_SOURCE"
if [ -f "$TARGET_DEPLOYED" ]; then
  validate_eut "$TARGET_DEPLOYED"
fi

echo "All EUT checks passed successfully!"
exit 0
