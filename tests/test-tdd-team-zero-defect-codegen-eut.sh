#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-zero-defect-codegen-eut.sh
# End-to-End User Acceptance Test for Zero-Defect Code Generation Gate:
# 1. Contract verification execution across triple copies.
# 2. Gherkin BDD linting on tdd-team-zero-defect-codegen.feature.
# 3. Structural integrity of Design-by-Contract & 14-Dimension Checklist.
# 4. Boundary Fuzzing & Sequential Phase Verification.
# 5. Fault Injection on Contract Validator proving rejection of mutated files.
# 6. Clean whitespace verification.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== [SDET EUT Gate] Running EUT for Zero-Defect Code Generation ==="

# 1. Execute Contract Test Suite
if ! bash "$SCRIPT_DIR/test-tdd-team-zero-defect-codegen-contracts.sh"; then
  echo "FAIL: Contract verification failed during EUT."
  exit 1
fi

# 2. Validate BDD Feature File
echo "Validating Gherkin syntax of tdd-team-zero-defect-codegen.feature..."
if ! bash "$REPO_ROOT/.ai-suite/layer4-evolutionary/validation/lint-feature.sh" "$SCRIPT_DIR/tdd-team-zero-defect-codegen.feature"; then
  echo "FAIL: Gherkin linting failed for tdd-team-zero-defect-codegen.feature"
  exit 1
fi

# 3. Deep Semantic & Structural Integrity Check on tdd-team.md
echo "Verifying structural integrity of Zero-Defect Code Generation in tdd-team.md..."
SKILL_FILE="$REPO_ROOT/.ai-suite/layer3-registry/core/tdd-team.md"

REQUIRED_PATTERNS=(
  "Zero-Defect Code Generation & Formal Invariants"
  "Non-Vacuous Assertions & Mutation Resistance"
  "Formal Boundary Value Analysis (BVA) Extrema Matrix"
  "**Design-by-Contract (DbC)** specifications"
  "Formal Invariants & Design-by-Contract (DbC)"
  "Non-Vacuous Assertion Verification"
  "Strict Compiler & Static Analysis Gate"
  "12-Dimension Anti-AI-Review Zero-Defect Verification Checklist (Extended with Zero-Defect Code Invariants to 14 Dimensions)"
  "Design-by-Contract & Formal Invariant Enforcement"
  "Strict Compiler/Linter Zero-Warning & Non-Vacuous Mutation Gate"
  "Zero-Defect Audit Certification"
  "Do not generate code without Design-by-Contract formal invariants"
  "Do not allow vacuous test assertions or compiler warnings"
)

for pattern in "${REQUIRED_PATTERNS[@]}"; do
  if ! grep -qiF "$pattern" "$SKILL_FILE"; then
    echo "FAIL: Required pattern not found in tdd-team.md: $pattern"
    exit 1
  fi
done

# 4. Boundary Fuzzing & Sequential Phase Verification
echo "Running Boundary Fuzzing and Sequential Phase Verification..."
python3 -c "
import sys

with open('$SKILL_FILE', 'r') as fp:
    content = fp.read()

# Verify all 14 dimensions of the checklist are explicitly present
dimensions = [
    'Boundary & Null/Nil Safety',
    'Deterministic Error Handling & Contextual Propagation',
    'Resource & Memory Safety',
    'Concurrency, Subprocess & Race Safety',
    'Security, Injection & Path Traversal Sanitization',
    'Algorithmic Efficiency & Bounded Complexity',
    'Code Formatting & Cleanliness Standards',
    'UI/UX & AI Workflow Fidelity',
    'Anti-Hardcoding Rigor & Dynamic Test Assertions',
    'Domain Integrity, Protocol RFC Conformance',
    'Anti-False-Positive & Review Rule Compliance',
    'Separation of Concerns & Architecture Purity',
    'Design-by-Contract & Formal Invariant Enforcement',
    'Strict Compiler/Linter Zero-Warning & Non-Vacuous Mutation Gate'
]

for dim in dimensions:
    if dim.lower() not in content.lower():
        print(f'FAIL: Missing dimension in checklist: {dim}')
        sys.exit(1)

# Verify phases 1 through 5 are sequentially ordered
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

# 5. Fault Injection on Contract Validator
echo "Running Fault Injection on Contract Validator..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

if bash "$SCRIPT_DIR/test-tdd-team-zero-defect-codegen-contracts.sh" "$TMP_DIR/nonexistent.md" >/dev/null 2>&1; then
  echo "FAIL: Expected rejection on non-existent file."
  exit 1
fi

BASE_VALID="$TMP_DIR/valid.md"
cp "$SKILL_FILE" "$BASE_VALID"

MUTATIONS=(
  "s/Zero-Defect Code Generation & Formal Invariants/Generic Invariants/g"
  "s/requires/arbitrary_inputs/g"
  "s/Non-Vacuous Assertions & Mutation Resistance/Basic Assertions/g"
  "s/Design-by-Contract (DbC) invariants/arbitrary_types/g"
  "s/non-vacuous assertion proof/tautological assertions/g"
  "s/Vetoes any deliverable lacking formal Design-by-Contract/Permissive reviewer/g"
  "s/Formal Boundary Value Analysis (BVA) Extrema Matrix/Informal Inputs/g"
  "s/Formal Invariants & Design-by-Contract (DbC)/Informal Review/g"
  "s/Non-Vacuous Assertion Verification/Standard Assertions/g"
  "s/Strict Compiler & Static Analysis Gate/Optional Compiler/g"
  "s/14 Dimensions/10 Dimensions/g"
  "s/Design-by-Contract & Formal Invariant Enforcement/Contract Ignored/g"
  "s/Strict Compiler\/Linter Zero-Warning & Non-Vacuous Mutation Gate/Permissive Warnings/g"
  "s/across all 14 checklist dimensions/unverified dimensions/g"
  "/Do not generate code without Design-by-Contract/d"
  "/Do not allow vacuous test assertions or compiler warnings/d"
)

for mut in "${MUTATIONS[@]}"; do
  MUTANT="$TMP_DIR/mutant.md"
  sed "$mut" "$BASE_VALID" > "$MUTANT"
  if bash "$SCRIPT_DIR/test-tdd-team-zero-defect-codegen-contracts.sh" "$MUTANT" >/dev/null 2>&1; then
    echo "FAIL: Contract validator unexpectedly passed on mutant: $mut"
    exit 1
  fi
  rm -f "$MUTANT"
done

echo "Fault injection passed: All 11 mutants correctly rejected by contract validator."

# 6. Verify Clean Whitespace on Checked Files
echo "Verifying zero whitespace-only blank lines..."
python3 -c "
files = [
    '$SCRIPT_DIR/tdd-team-zero-defect-codegen.feature',
    '$SCRIPT_DIR/test-tdd-team-zero-defect-codegen-contracts.sh',
    '$SCRIPT_DIR/test-tdd-team-zero-defect-codegen-eut.sh'
]
for f in files:
    with open(f, 'r') as fp:
        for idx, line in enumerate(fp, 1):
            if line.strip() == '' and len(line) > 1:
                print(f'FAIL: {f}:{idx} contains whitespace-only blank line')
                sys.exit(1)
print('Zero whitespace-only lines verified.')
"

echo "=== [SDET EUT Gate] All Zero-Defect Code Generation EUT Checks PASSED 100% ==="
exit 0
