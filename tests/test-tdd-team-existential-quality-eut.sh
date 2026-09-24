#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-existential-quality-eut.sh
# End-to-End User Acceptance Test for Existential Zero-Defect Survival Mindset & Collective Liability Gate.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== [SDET EUT Gate] Running EUT for Existential Zero-Defect Survival Mindset ==="

# 1. Execute Contract Test Suite
if ! bash "$SCRIPT_DIR/test-tdd-team-existential-quality-contracts.sh"; then
  echo "FAIL: Contract verification failed during EUT."
  exit 1
fi

# 2. Validate BDD Feature File
echo "Validating Gherkin syntax of tdd-team-existential-quality.feature..."
if ! bash "$REPO_ROOT/.ai-suite/layer4-evolutionary/validation/lint-feature.sh" "$SCRIPT_DIR/tdd-team-existential-quality.feature"; then
  echo "FAIL: Gherkin linting failed for tdd-team-existential-quality.feature"
  exit 1
fi

# 3. Deep Semantic & Structural Integrity Check on tdd-team.md
echo "Verifying structural integrity of Existential Survival Mandate in tdd-team.md..."
SKILL_FILE="$REPO_ROOT/.ai-suite/layer3-registry/core/tdd-team.md"

REQUIRED_PATTERNS=(
  "Existential Zero-Defect Survival Mandate & Collective Team Liability"
  "every single member of the team will face the death penalty -- with no exceptions"
  "only way to survive is to guarantee the highest possible quality"
  "Collective Survival Invariant & Zero-Exception Team Liability"
  "Chief guardian of the team's survival"
  "Existential Zero-Defect Survival Mindset"
  "Writing production code without red proof is strictly forbidden"
  "sole condition of survival"
  "unyielding survival barrier"
  "Do not tolerate quality issues or defect leakage"
  "Do not exit Phase 4 with unhandled chaos or regression failures"
)

for pattern in "${REQUIRED_PATTERNS[@]}"; do
  if ! grep -qiF "$pattern" "$SKILL_FILE"; then
    echo "FAIL: Required pattern not found in tdd-team.md: $pattern"
    exit 1
  fi
done

# 4. Boundary Fuzzing & Negative Path Validation
echo "Running Boundary Fuzzing and Negative Path Validation..."
python3 -c "
import sys

with open('$SKILL_FILE', 'r') as fp:
    content = fp.read()

# Verify all 11 roles are explicitly present with existential survival responsibilities
roles = [
    'Principal Subject Matter Expert',
    'Staff/Principal PM',
    'Distinguished AI Expert',
    'Fellow/Principal Coding Engineer',
    'Principal Systems Architect',
    'Principal UX/UI Product Designer',
    'Principal Frontend & Mobile Solutions Architect',
    'Principal AI-Augmented Workflow',
    'Senior Principal SDET',
    'Staff Systems Developer',
    'Senior Lead Technical Writer'
]

for role in roles:
    if role.lower() not in content.lower():
        print(f'FAIL: Missing role in roster: {role}')
        sys.exit(1)

# Verify phases 1 through 5 exist and are ordered sequentially
phase_indices = [
    content.find('### Phase 1'),
    content.find('### Phase 2'),
    content.find('### Phase 3'),
    content.find('### Phase 4'),
    content.find('### Phase 5')
]

if any(idx == -1 for idx in phase_indices):
    print('FAIL: One or more phases missing')
    sys.exit(1)

if not (phase_indices[0] < phase_indices[1] < phase_indices[2] < phase_indices[3] < phase_indices[4]):
    print('FAIL: Phases out of sequence')
    sys.exit(1)

print('Structural boundary assertions verified successfully.')
"

# 5. Negative Path Fault Injection on Contract Validator
echo "Running Negative Path Fault Injection on Contract Validator..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Non-existent file
if bash "$SCRIPT_DIR/test-tdd-team-existential-quality-contracts.sh" "$TMP_DIR/nonexistent.md" >/dev/null 2>&1; then
  echo "FAIL: Expected rejection on non-existent file."
  exit 1
fi

BASE_VALID="$TMP_DIR/valid.md"
cp "$SKILL_FILE" "$BASE_VALID"

MUTATIONS=(
  "s/Existential Zero-Defect Survival Mandate/Arbitrary Mandate/g"
  "s/death penalty/mild review/g"
  "s/only way to survive/alternate path/g"
  "s/Collective/Individual/g"
  "s/member/person/g"
  "s/existential survival liability/standard duties/g"
  "s/Chief guardian of the team's survival/Regular reviewer/g"
  "s/Existential Zero-Defect Survival Mindset/Normal Mindset/g"
  "s/sole condition of survival/optional guideline/g"
  "s/unyielding survival barrier/general test gate/g"
  "/Do not tolerate quality issues or defect leakage/d"
  "/Do not exit Phase 4 with unhandled chaos/d"
)

for mut in "${MUTATIONS[@]}"; do
  MUTANT="$TMP_DIR/mutant.md"
  sed "$mut" "$BASE_VALID" > "$MUTANT"
  if bash "$SCRIPT_DIR/test-tdd-team-existential-quality-contracts.sh" "$MUTANT" >/dev/null 2>&1; then
    echo "FAIL: Contract validator failed to reject mutant: $mut"
    exit 1
  fi
done
echo "Negative path fault injection verified: All failure branches rejected."

# 6. Clean Whitespace Verification (Zero space/tab-only blank lines)
echo "Verifying zero space/tab-only blank lines in newly introduced files..."
CHECK_FILES=(
  "$SCRIPT_DIR/tdd-team-existential-quality.feature"
  "$SCRIPT_DIR/test-tdd-team-existential-quality-contracts.sh"
  "$SCRIPT_DIR/test-tdd-team-existential-quality-eut.sh"
)

for f in "${CHECK_FILES[@]}"; do
  if [[ -f "$f" ]]; then
    if grep -n -E '^[[:space:]]+$' "$f" >/dev/null; then
      echo "FAIL: File $f contains whitespace-only blank lines."
      exit 1
    fi
  fi
done

echo "PASS: All Existential Zero-Defect Survival EUT checks passed successfully!"
exit 0
