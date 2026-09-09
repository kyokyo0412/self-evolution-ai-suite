#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-web-mobile-ai-eut.sh
# End-to-End User Acceptance Test for Web/Mobile & AI Workflow in tdd-team skill

echo "Running EUT for Web/Mobile & AI Workflow in tdd-team skill..."

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

validate_web_mobile_ai_eut() {
  local file="$1"
  echo "Evaluating Web/Mobile & AI Workflow EUT on $file..."

  # 1. Roster verification
  grep -qi "Principal UX/UI Product Designer" "$file"
  grep -qi "Principal Frontend & Mobile Solutions Architect" "$file"
  grep -qi "Principal AI-Augmented Workflow" "$file"

  # 2. Persona & Guidelines verification
  grep -qi "Team Persona & UI/UX Guidelines" "$file"
  grep -qi "Aesthetics" "$file"
  grep -qi "Usability" "$file"
  grep -qi "dumb" "$file"
  grep -qi "Accessibility" "$file"
  grep -qi "Consistency" "$file"

  # 3. Stage-gated procedures
  grep -qi "color palette" "$file"
  grep -qi "typography hierarchy" "$file"
  grep -qi "spacing rules" "$file"
  grep -qi "interaction states" "$file"
  grep -qi "modern tech stack" "$file"
  grep -qi "custom hooks" "$file"
  grep -qi "optimistic UI" "$file" || grep -qi "streaming" "$file"

  # 4. Backward compatibility
  grep -qi "Staff/Principal PM" "$file"
  grep -qi "Distinguished AI Expert" "$file"
  grep -qi "Fellow/Principal Engineer" "$file"
  grep -qi "Senior Principal SDET" "$file"
  grep -qi "Staff Systems Developer" "$file"
  grep -qi "Senior Lead Technical Writer" "$file"
  grep -qi "README.md" "$file"
  grep -qi "Do not skip Role Visibility" "$file"
  grep -qi "review the \`*tdd-team\`* skill" "$file"

  echo "EUT evaluation passed for $file"
}

validate_web_mobile_ai_eut "$TARGET_SOURCE"
if [ -f "$TARGET_CURSOR" ]; then
  validate_web_mobile_ai_eut "$TARGET_CURSOR"
fi
if [ -f "$TARGET_CODEX" ]; then
  validate_web_mobile_ai_eut "$TARGET_CODEX"
fi

echo "All Web/Mobile & AI Workflow EUT checks passed successfully!"
exit 0
