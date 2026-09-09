#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-mutation.sh
# Automated Mutation Analysis & Contract Fragility Testing for tdd-team skill

echo "=== Starting Order-5 Mutation Analysis for tdd-team Skill Contracts ==="

SOURCE_FILE=".ai-suite/layer3-registry/core/tdd-team.md"
if [ ! -f "$SOURCE_FILE" ]; then
  echo "ERROR: Source file $SOURCE_FILE does not exist."
  exit 1
fi

SANDBOX=$(mktemp -d "/tmp/tdd-team-mutation.XXXXXX")
trap 'rm -rf "$SANDBOX"' EXIT

TOTAL_MUTANTS=0
KILLED_MUTANTS=0
SURVIVED_MUTANTS=0

run_mutation_test() {
  local mutant_name="$1"
  local test_cmd="$2"
  local mutant_file="$3"

  TOTAL_MUTANTS=$((TOTAL_MUTANTS + 1))
  echo -n "  Testing mutant $TOTAL_MUTANTS [$mutant_name] ... "

  if bash $test_cmd "$mutant_file" >/dev/null 2>&1; then
    echo "FAILED (Mutant SURVIVED! Test suite is fragile or tautological)"
    SURVIVED_MUTANTS=$((SURVIVED_MUTANTS + 1))
  else
    echo "PASSED (Mutant KILLED as expected)"
    KILLED_MUTANTS=$((KILLED_MUTANTS + 1))
  fi
}

# Baseline verification: unmutated file MUST pass all contract suites
echo "1. Baseline Check (Unmutated Source must pass 100%):"
bash tests/test-tdd-team-domain-sme-contracts.sh "$SOURCE_FILE" >/dev/null 2>&1 || { echo "ERROR: Baseline SME check failed"; exit 1; }
bash tests/test-tdd-team-concurrency-race-contracts.sh "$SOURCE_FILE" >/dev/null 2>&1 || { echo "ERROR: Baseline concurrency check failed"; exit 1; }
bash tests/test-tdd-team-adverse-chaos-contracts.sh "$SOURCE_FILE" >/dev/null 2>&1 || { echo "ERROR: Baseline chaos check failed"; exit 1; }
bash tests/test-tdd-team-resource-safety-contracts.sh "$SOURCE_FILE" >/dev/null 2>&1 || { echo "ERROR: Baseline resource safety check failed"; exit 1; }
echo "   Baseline verification passed 100%."

echo "2. Injecting and Evaluating Code Mutations:"

# Mutant 1: Remove Principal SME role
M1="$SANDBOX/m1.md"
sed '/Principal Subject Matter Expert (SME)/d' "$SOURCE_FILE" > "$M1"
run_mutation_test "Remove Principal SME role" "tests/test-tdd-team-domain-sme-contracts.sh" "$M1"

# Mutant 2: Change eleven-role to ten-role
M2="$SANDBOX/m2.md"
sed 's/eleven-role/ten-role/g' "$SOURCE_FILE" > "$M2"
run_mutation_test "Revert eleven-role to ten-role" "tests/test-tdd-team-domain-sme-contracts.sh" "$M2"

# Mutant 3: Remove Domain Classification & Risk Profiling
M3="$SANDBOX/m3.md"
sed 's/Domain Classification & Risk Profiling/Generic Requirements Discovery/g' "$SOURCE_FILE" > "$M3"
run_mutation_test "Mutate Domain Classification to Generic Requirements" "tests/test-tdd-team-domain-sme-contracts.sh" "$M3"

# Mutant 4: Remove Domain Context Matrix
M4="$SANDBOX/m4.md"
sed 's/Domain Context Matrix/General Overview Notes/g' "$SOURCE_FILE" > "$M4"
run_mutation_test "Mutate Domain Context Matrix to General Overview Notes" "tests/test-tdd-team-domain-sme-contracts.sh" "$M4"

# Mutant 5: Remove Negative Constraint against bypassing Domain Profiling
M5="$SANDBOX/m5.md"
sed '/Do not bypass Domain Classification & Risk Profiling/d' "$SOURCE_FILE" > "$M5"
run_mutation_test "Remove Negative Constraint against bypassing Domain Profiling" "tests/test-tdd-team-domain-sme-contracts.sh" "$M5"

# Mutant 6: Remove distributed lock leases in Phase 2.1
M6="$SANDBOX/m6.md"
sed 's/distributed lock leases/standard locks/g' "$SOURCE_FILE" > "$M6"
run_mutation_test "Mutate distributed lock leases to standard locks" "tests/test-tdd-team-concurrency-race-contracts.sh" "$M6"

# Mutant 7: Remove domain chaos injection in Phase 4
M7="$SANDBOX/m7.md"
sed 's/network partition simulation/standard mock network/g' "$SOURCE_FILE" > "$M7"
run_mutation_test "Mutate network partition simulation to standard mock network" "tests/test-tdd-team-adverse-chaos-contracts.sh" "$M7"

# Mutant 8: Remove 1E-Class deterministic bounds in Phase 3.5
M8="$SANDBOX/m8.md"
sed 's/1E-Class Standards/Standard Guidelines/g' "$SOURCE_FILE" > "$M8"
run_mutation_test "Mutate 1E-Class Standards to Standard Guidelines" "tests/test-tdd-team-resource-safety-contracts.sh" "$M8"

# Mutant 9: Remove Reviewer rejection on SME bounds in Phase 1.4
M9="$SANDBOX/m9.md"
sed '/Dynamic SME determines that domain-specific compliance, safety, or protocol bounds were omitted/d' "$SOURCE_FILE" > "$M9"
run_mutation_test "Remove Reviewer domain rejection rule in Phase 1.4" "tests/test-tdd-team-domain-sme-contracts.sh" "$M9"

# Mutant 10: Remove Domain Traceability Matrix in Phase 5
M10="$SANDBOX/m10.md"
sed '/Domain Compliance & Regulatory Traceability Matrix/d' "$SOURCE_FILE" > "$M10"
run_mutation_test "Remove Domain Compliance Traceability Matrix in Phase 5" "tests/test-tdd-team-domain-sme-contracts.sh" "$M10"

echo "=== Mutation Analysis Results ==="
echo "Total Mutants Evaluated: $TOTAL_MUTANTS"
echo "Killed Mutants:          $KILLED_MUTANTS"
echo "Survived Mutants:        $SURVIVED_MUTANTS"

if [ "$SURVIVED_MUTANTS" -gt 0 ]; then
  echo "OVERALL FAIL: Mutation testing discovered $SURVIVED_MUTANTS surviving mutant(s)!"
  exit 1
fi

echo "OVERALL SUCCESS: 100% Mutation Score! All $TOTAL_MUTANTS mutants were successfully killed."
exit 0
