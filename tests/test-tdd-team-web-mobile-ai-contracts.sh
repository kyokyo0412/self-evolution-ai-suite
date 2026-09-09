#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-web-mobile-ai-contracts.sh
# Validates that tdd-team skill includes UX/UI Designer, Frontend Architect, AI Workflow roles,
# UI/UX guidelines, design systems, dumb components, custom hook separation, and AI-augmented workflows.

check_web_mobile_ai_contracts() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating Web/Mobile & AI Workflow contracts in: $file"

  # 1. New Senior Roles in Roster
  echo "  Checking UX/UI Designer Role..."
  if ! grep -qi "UX/UI.*Designer\|Design Systems" "$file"; then
    echo "  FAIL: Principal UX/UI Designer role missing in $file"
    return 1
  fi

  echo "  Checking Frontend & Mobile Architect Role..."
  if ! grep -qi "Frontend.*Architect\|Mobile.*Architect" "$file"; then
    echo "  FAIL: Principal Frontend & Mobile Architect role missing in $file"
    return 1
  fi

  echo "  Checking AI-Augmented Workflow Role..."
  if ! grep -qi "AI-Augmented Workflow\|Interaction Engineer" "$file"; then
    echo "  FAIL: Principal AI-Augmented Workflow role missing in $file"
    return 1
  fi

  # 2. Team Persona & UI/UX Guidelines
  echo "  Checking Team Persona & UI/UX Guidelines..."
  if ! grep -qi "Aesthetics" "$file" || ! grep -qi "rounded\|shadow" "$file"; then
    echo "  FAIL: UI/UX Aesthetics guidelines missing in $file"
    return 1
  fi

  if ! grep -qi "Usability" "$file" || ! grep -qi "hover.*focus.*active\|visual feedback" "$file"; then
    echo "  FAIL: UI/UX Usability guidelines missing in $file"
    return 1
  fi

  if ! grep -qi "dumb" "$file" || ! grep -qi "custom hook\|state management" "$file"; then
    echo "  FAIL: UI Logic separation (dumb components / custom hooks) missing in $file"
    return 1
  fi

  if ! grep -qi "Accessibility\|aria-labels" "$file" || ! grep -qi "contrast\|semantic" "$file"; then
    echo "  FAIL: Accessibility guidelines (aria-labels, contrast) missing in $file"
    return 1
  fi

  if ! grep -qi "Consistency" "$file" || ! grep -qi "tailwind\.config\|theme" "$file"; then
    echo "  FAIL: Design consistency / theme token guidelines missing in $file"
    return 1
  fi

  # 3. Phase 1 Design System Proposition
  echo "  Checking Phase 1 Design System Proposition..."
  if ! grep -qi "color palette" "$file" || ! grep -qi "typography" "$file" || ! grep -qi "spacing" "$file"; then
    echo "  FAIL: Phase 1 Design system criteria (color palette, typography, spacing) missing in $file"
    return 1
  fi

  # 4. Phase 2 Frontend Tech Stack & Component Architecture
  echo "  Checking Phase 2 Tech Stack & Architecture..."
  if ! grep -qi "tech stack" "$file" || ! grep -qi "framework\|styling library" "$file"; then
    echo "  FAIL: Phase 2 Frontend Tech stack criteria missing in $file"
    return 1
  fi

  # 5. AI-Augmented Workflow Integration
  echo "  Checking AI-Augmented Workflow elements..."
  if ! grep -qi "AI-augmented" "$file" || ! grep -qi "streaming\|optimistic" "$file"; then
    echo "  FAIL: AI-augmented workflow integration missing in $file"
    return 1
  fi

  # 6. Mobile Touch Ergonomics & Accessibility Standards
  echo "  Checking Mobile Touch & Accessibility deep standards..."
  if ! grep -qi "44" "$file" || ! grep -qi "WCAG" "$file"; then
    echo "  FAIL: Mobile touch target (44px) or WCAG accessibility missing in $file"
    return 1
  fi

  # 7. Order-4 Domain-Tailored UI/UX & AI Workflow Ergonomics
  echo "  Checking Domain Ergonomics & AI Fallback in UI/UX..."
  if ! grep -qi "domain-specific ergonomic patterns\|high-density financial data tables\|telemetry gauges\|clinical patient card" "$file"; then
    echo "  FAIL: Domain-specific ergonomic UI patterns missing in $file"
    return 1
  fi

  echo "  PASS: All Web/Mobile & AI Workflow contracts verified for $file"
  return 0
}

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

PASS_COUNT=0
FAIL_COUNT=0

if check_web_mobile_ai_contracts "$TARGET_SOURCE"; then
  PASS_COUNT=$((PASS_COUNT + 1))
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if [ -f "$TARGET_CURSOR" ]; then
  if check_web_mobile_ai_contracts "$TARGET_CURSOR"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ -f "$TARGET_CODEX" ]; then
  if check_web_mobile_ai_contracts "$TARGET_CODEX"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed Web/Mobile & AI Workflow contract verification."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT checked files passed Web/Mobile & AI Workflow contract verification."
exit 0
