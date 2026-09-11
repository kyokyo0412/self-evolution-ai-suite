#!/bin/bash
set -euo pipefail

SKILL_FILE=".ai-suite/layer3-registry/core/loop-work.md"

if [ ! -f "$SKILL_FILE" ]; then
  echo "Error: $SKILL_FILE not found."
  exit 1
fi

echo "Validating loop-work.md for Identical Full Task Iteration Invariant..."

# 1. Check for identical task target requirement across iterations
if ! grep -qiE "same.*task.*target|identical.*task.*target|repeat.*same.*task" "$SKILL_FILE"; then
  echo "RED: Missing directive that all iterations must repeat the same task with identical task target."
  exit 1
fi

# 2. Check for explicit negative constraint against splitting target file/code into parts or chunks (Spatial Partitioning)
if ! grep -qiE "not.*split.*(file|codebase|target|part|chunk)" "$SKILL_FILE"; then
  echo "RED: Missing negative constraint forbidding splitting target/file into parts across iterations."
  exit 1
fi

# 3. Check for explicit negative constraint against splitting review aspects/categories across iterations (Dimensional Partitioning)
if ! grep -qiE "not.*split.*aspect|not.*split.*(dimension|category|check)" "$SKILL_FILE"; then
  echo "RED: Missing negative constraint forbidding splitting review aspects across iterations."
  exit 1
fi

# 4. Check for explicit negative constraint against spreading workflow phases across iterations (Phasing Partitioning)
if ! grep -qiE "not.*spread.*workflow.*phase|not.*split.*phase" "$SKILL_FILE"; then
  echo "RED: Missing negative constraint forbidding spreading workflow phases across iterations."
  exit 1
fi

# 4b. Check for explicit negative constraint against Hardening Phase Partitioning
if ! grep -qiE "Hardening Phase Partitioning|not.*defer.*hardening" "$SKILL_FILE"; then
  echo "RED: Missing negative constraint forbidding Hardening Phase Partitioning across iterations."
  exit 1
fi

# 5. Check for full review / full execution on every single iteration
if ! grep -qiE "every iteration.*(full|entire|complete)|each iteration.*(full|entire|complete)" "$SKILL_FILE"; then
  echo "RED: Missing directive ensuring every iteration executes on the full/complete target."
  exit 1
fi

# 6. Check for concrete exemplar illustrating non-partitioned full iteration
if ! grep -qiE "review file|100 times|review.*100" "$SKILL_FILE"; then
  echo "RED: Missing concrete exemplar of reviewing full file/target repeatedly."
  exit 1
fi

# 7. Check for in-iteration bug fixing and cumulative hardening
if ! grep -qiE "fix.*within.*iteration|fix.*in.*iteration" "$SKILL_FILE"; then
  echo "RED: Missing directive to fix bugs within the current iteration."
  exit 1
fi

# 8. Check for LLM reasoning & validation with cognitive self-check questions
if ! grep -qiE "LLM reasoning|LLM thinking" "$SKILL_FILE"; then
  echo "RED: Missing LLM reasoning validation directive."
  exit 1
fi

# 9. Check for isolation principle and self-evolution preservation
if ! grep -qiE "isolation principle" "$SKILL_FILE" || ! grep -qiE "self-evolution" "$SKILL_FILE"; then
  echo "RED: Missing isolation principle or self-evolution preservation directives."
  exit 1
fi

echo "GREEN: Identical Full Task Iteration Invariant requirements validated successfully."
exit 0
