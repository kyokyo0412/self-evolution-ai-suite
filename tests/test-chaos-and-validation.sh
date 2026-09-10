#!/usr/bin/env bash
# tests/test-chaos-and-validation.sh -- Chaos injection, adversarial fuzzing & validation suite tests
set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_CLI="$SUITE_ROOT/ai-suite"
VALIDATOR_SUITE="$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh"
LINT_FEATURE="$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/lint-feature.sh"
VALIDATE_REQ="$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/validate-requirements.sh"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== TDD Module 6: Chaos Injection, Adversarial Fuzzing & Validation Suite ==="

TMP_SANDBOX=$(mktemp -d "${TMPDIR:-/tmp}/tdd-chaos-validation.XXXXXX")
trap 'rm -rf "$TMP_SANDBOX"' EXIT

# ==============================================================================
# SECTION 1: validate-requirements.sh Testing
# ==============================================================================

# 1. validate-requirements on current valid repository feature
set +e
REQ_OUT=$(bash "$VALIDATE_REQ" 2>&1)
REQ_CODE=$?
set -e
if [[ $REQ_CODE -eq 0 ]] && [[ "$REQ_OUT" == *"PASS: Requirements Validation"* ]]; then
  pass "validate-requirements: passes on valid unified workflow specification"
else
  fail "validate-requirements: failed on valid specification (code: $REQ_CODE)"
fi

# 2. validate-requirements fails when feature file is missing
(
  cd "$TMP_SANDBOX"
  set +e
  REQ_MISSING=$(bash "$VALIDATE_REQ" 2>&1)
  REQ_MISS_CODE=$?
  set -e
  if [[ $REQ_MISS_CODE -ne 0 ]] && [[ "$REQ_MISSING" == *"FAIL: Feature file not found"* ]]; then
    pass "validate-requirements: fails safely when feature file is missing"
  else
    fail "validate-requirements: allowed missing feature file (code: $REQ_MISS_CODE)"
  fi
)

# 3. validate-requirements fails when a required scenario is missing
CORRUPT_REQ_DIR="$TMP_SANDBOX/corrupt_req/tests"
mkdir -p "$CORRUPT_REQ_DIR"
cat > "$CORRUPT_REQ_DIR/test-unified-workflow.feature" << 'EOF'
Feature: Incomplete Feature
  Scenario: Enable the AI suite
  Scenario: Disable the AI suite
EOF
(
  cd "$TMP_SANDBOX/corrupt_req"
  set +e
  REQ_INCOMP=$(bash "$VALIDATE_REQ" 2>&1)
  REQ_INCOMP_CODE=$?
  set -e
  if [[ $REQ_INCOMP_CODE -ne 0 ]] && [[ "$REQ_INCOMP" == *"FAIL: Missing scenario"* ]]; then
    pass "validate-requirements: rejects incomplete feature missing required scenarios"
  else
    fail "validate-requirements: allowed incomplete scenarios (code: $REQ_INCOMP_CODE)"
  fi
)

# ==============================================================================
# SECTION 2: lint-feature.sh Adversarial Testing
# ==============================================================================

# 4. lint-feature on valid feature file
set +e
LF_PASS=$(bash "$LINT_FEATURE" "$SUITE_ROOT/tests/test-unified-workflow.feature" 2>&1)
LF_PASS_CODE=$?
set -e
if [[ $LF_PASS_CODE -eq 0 ]] && [[ "$LF_PASS" == *"checks passed"* ]]; then
  pass "lint-feature: cleanly passes on valid Gherkin feature file"
else
  fail "lint-feature: failed on valid feature file (code: $LF_PASS_CODE)"
fi

# 5. lint-feature on non-existent file
set +e
LF_NOFILE=$(bash "$LINT_FEATURE" "$TMP_SANDBOX/does_not_exist.feature" 2>&1)
LF_NOFILE_CODE=$?
set -e
if [[ $LF_NOFILE_CODE -ne 0 ]] && [[ "$LF_NOFILE" == *"feature file not found"* ]]; then
  pass "lint-feature: rejects non-existent feature file"
else
  fail "lint-feature: allowed non-existent file (code: $LF_NOFILE_CODE)"
fi

# 6. lint-feature on empty file
EMPTY_FEAT="$TMP_SANDBOX/empty.feature"
touch "$EMPTY_FEAT"
set +e
LF_EMPTY=$(bash "$LINT_FEATURE" "$EMPTY_FEAT" 2>&1)
LF_EMPTY_CODE=$?
set -e
if [[ $LF_EMPTY_CODE -ne 0 ]] && [[ "$LF_EMPTY" == *"feature file is empty"* ]]; then
  pass "lint-feature: rejects empty feature file"
else
  fail "lint-feature: allowed empty file (code: $LF_EMPTY_CODE)"
fi

# 7. lint-feature on file with no Feature: heading
NO_FEAT_HEADING="$TMP_SANDBOX/no_heading.feature"
cat > "$NO_FEAT_HEADING" << 'EOF'
Scenario: Orphan Scenario
  When something happens
  Then something exists
EOF
set +e
LF_NO_HEAD=$(bash "$LINT_FEATURE" "$NO_FEAT_HEADING" 2>&1)
LF_NO_HEAD_CODE=$?
set -e
if [[ $LF_NO_HEAD_CODE -ne 0 ]] && [[ "$LF_NO_HEAD" == *"no 'Feature:' heading found"* ]]; then
  pass "lint-feature: rejects file missing 'Feature:' heading"
else
  fail "lint-feature: allowed missing Feature heading (code: $LF_NO_HEAD_CODE)"
fi

# 8. lint-feature on file with no Scenario: blocks
NO_SCENARIO="$TMP_SANDBOX/no_scenario.feature"
cat > "$NO_SCENARIO" << 'EOF'
Feature: Empty Feature Without Scenarios
EOF
set +e
LF_NO_SCEN=$(bash "$LINT_FEATURE" "$NO_SCENARIO" 2>&1)
LF_NO_SCEN_CODE=$?
set -e
if [[ $LF_NO_SCEN_CODE -ne 0 ]] && [[ "$LF_NO_SCEN" == *"no 'Scenario:' blocks found"* ]]; then
  pass "lint-feature: rejects file missing 'Scenario:' blocks"
else
  fail "lint-feature: allowed missing Scenario blocks (code: $LF_NO_SCEN_CODE)"
fi

# 9. lint-feature on scenario missing When step
NO_WHEN="$TMP_SANDBOX/no_when.feature"
cat > "$NO_WHEN" << 'EOF'
Feature: Incomplete Scenario
  Scenario: Missing When
    Given something is true
    Then something is verified
EOF
set +e
LF_NO_WHEN=$(bash "$LINT_FEATURE" "$NO_WHEN" 2>&1)
LF_NO_WHEN_CODE=$?
set -e
if [[ $LF_NO_WHEN_CODE -ne 0 ]] && [[ "$LF_NO_WHEN" == *"has no When step"* ]]; then
  pass "lint-feature: detects and rejects scenario missing 'When' step"
else
  fail "lint-feature: allowed missing When step (code: $LF_NO_WHEN_CODE)"
fi

# 10. lint-feature on scenario missing Then step
NO_THEN="$TMP_SANDBOX/no_then.feature"
cat > "$NO_THEN" << 'EOF'
Feature: Incomplete Scenario
  Scenario: Missing Then
    Given something is true
    When something happens
EOF
set +e
LF_NO_THEN=$(bash "$LINT_FEATURE" "$NO_THEN" 2>&1)
LF_NO_THEN_CODE=$?
set -e
if [[ $LF_NO_THEN_CODE -ne 0 ]] && [[ "$LF_NO_THEN" == *"has no Then step"* ]]; then
  pass "lint-feature: detects and rejects scenario missing 'Then' step"
else
  fail "lint-feature: allowed missing Then step (code: $LF_NO_THEN_CODE)"
fi

# 11. lint-feature on placeholder tokens ([FILL], TODO, FIXME)
PLACEHOLDER_FEAT="$TMP_SANDBOX/placeholder.feature"
cat > "$PLACEHOLDER_FEAT" << 'EOF'
Feature: Unfinished Specs
  Scenario: Contains placeholders
    When the user runs TODO action
    Then [FILL] expected outcome
EOF
set +e
LF_PLACEHOLDER=$(bash "$LINT_FEATURE" "$PLACEHOLDER_FEAT" 2>&1)
LF_PLACE_CODE=$?
set -e
if [[ $LF_PLACE_CODE -ne 0 ]] && [[ "$LF_PLACEHOLDER" == *"unfilled placeholder"* ]]; then
  pass "lint-feature: detects and rejects unresolved placeholder tokens"
else
  fail "lint-feature: allowed unresolved placeholder tokens (code: $LF_PLACE_CODE)"
fi

# ==============================================================================
# SECTION 3: validate-suite.sh Single-File & Adversarial Skill Fuzzing
# ==============================================================================

# Create a valid baseline skill file
VALID_SKILL="$TMP_SANDBOX/valid-test-skill.md"
cat > "$VALID_SKILL" << 'EOF'
---
name: valid-test-skill
description: Valid test skill for validation engine. Use when testing suite validation.
triggers:
  - test skill
---
# Valid Test Skill

## Instructions
1. Run step 1.

## Negative Constraints
- Never delete root.
EOF

# 12. validate-suite on valid single skill file
set +e
VS_VALID=$(bash "$VALIDATOR_SUITE" "$VALID_SKILL" 2>&1)
VS_VALID_CODE=$?
set -e
if [[ $VS_VALID_CODE -eq 0 ]] && [[ "$VS_VALID" == *"0 failed"* ]]; then
  pass "validate-suite: passes single-file validation on valid skill"
else
  fail "validate-suite: failed on valid single skill (code: $VS_VALID_CODE)"
fi

# 13. Skill missing closing frontmatter delimiter within 20 lines
NO_CLOSE_FM="$TMP_SANDBOX/no-close-fm.md"
cat > "$NO_CLOSE_FM" << 'EOF'
---
name: no-close-fm
description: Missing closing delimiter. Use when testing.
triggers:
  - test
# Body begins without closing dashes
## Instructions
1. Step
## Negative Constraints
- None
EOF
set +e
VS_NO_CLOSE=$(bash "$VALIDATOR_SUITE" "$NO_CLOSE_FM" 2>&1)
set -e
if [[ "$VS_NO_CLOSE" == *"closing --- not found within first 20 lines"* ]]; then
  pass "validate-suite: rejects skill missing closing frontmatter delimiter within 20 lines"
else
  fail "validate-suite: allowed missing closing frontmatter delimiter"
fi

# 14. Skill missing name in frontmatter
NO_NAME_SKILL="$TMP_SANDBOX/no-name-skill.md"
cat > "$NO_NAME_SKILL" << 'EOF'
---
description: Missing name property. Use when testing.
triggers:
  - test
---
# Instructions
1. Step
## Negative Constraints
- None
EOF
set +e
VS_NO_NAME=$(bash "$VALIDATOR_SUITE" "$NO_NAME_SKILL" 2>&1)
set -e
if [[ "$VS_NO_NAME" == *"missing 'name:' in frontmatter"* ]]; then
  pass "validate-suite: rejects skill with missing name attribute"
else
  fail "validate-suite: allowed missing name attribute"
fi

# 15. Skill with invalid name characters (uppercase / symbols)
BAD_CHAR_NAME="$TMP_SANDBOX/Bad_Name!.md"
cat > "$BAD_CHAR_NAME" << 'EOF'
---
name: Bad_Name!
description: Invalid characters. Use when testing.
triggers:
  - test
---
# Instructions
1. Step
## Negative Constraints
- None
EOF
set +e
VS_BAD_CHAR=$(bash "$VALIDATOR_SUITE" "$BAD_CHAR_NAME" 2>&1)
set -e
if [[ "$VS_BAD_CHAR" == *"must match ^[a-z0-9-]+$"* ]]; then
  pass "validate-suite: rejects skill with invalid characters in name"
else
  fail "validate-suite: allowed invalid characters in name"
fi

# 16. Skill with name exceeding 64 characters
LONG_NAME="a-very-long-skill-name-that-exceeds-sixty-four-characters-limit-in-the-schema"
LONG_NAME_FILE="$TMP_SANDBOX/${LONG_NAME}.md"
cat > "$LONG_NAME_FILE" << EOF
---
name: $LONG_NAME
description: Too long name. Use when testing.
triggers:
  - test
---
# Instructions
1. Step
## Negative Constraints
- None
EOF
set +e
VS_LONG_NAME=$(bash "$VALIDATOR_SUITE" "$LONG_NAME_FILE" 2>&1)
set -e
if [[ "$VS_LONG_NAME" == *"name length"*" > 64"* ]]; then
  pass "validate-suite: rejects skill with name exceeding 64 characters"
else
  fail "validate-suite: allowed name exceeding 64 characters"
fi

# 17. Skill with name mismatching basename
MISMATCH_FILE="$TMP_SANDBOX/actual-filename.md"
cat > "$MISMATCH_FILE" << 'EOF'
---
name: different-name
description: Name does not match basename. Use when testing.
triggers:
  - test
---
# Instructions
1. Step
## Negative Constraints
- None
EOF
set +e
VS_MISMATCH=$(bash "$VALIDATOR_SUITE" "$MISMATCH_FILE" 2>&1)
set -e
if [[ "$VS_MISMATCH" == *"must equal filename basename"* ]]; then
  pass "validate-suite: rejects skill whose name does not match file basename"
else
  fail "validate-suite: allowed mismatched name and filename"
fi

# 18. Skill missing description or description without 'Use when'
NO_DESC_FILE="$TMP_SANDBOX/no-desc-skill.md"
cat > "$NO_DESC_FILE" << 'EOF'
---
name: no-desc-skill
triggers:
  - test
---
# Instructions
1. Step
## Negative Constraints
- None
EOF
set +e
VS_NO_DESC=$(bash "$VALIDATOR_SUITE" "$NO_DESC_FILE" 2>&1)
set -e
if [[ "$VS_NO_DESC" == *"missing 'description:' in frontmatter"* ]]; then
  pass "validate-suite: rejects skill with missing description"
else
  fail "validate-suite: allowed missing description"
fi

NO_USE_WHEN="$TMP_SANDBOX/no-use-when.md"
cat > "$NO_USE_WHEN" << 'EOF'
---
name: no-use-when
description: This description does not tell the agent the trigger conditions.
triggers:
  - test
---
# Instructions
1. Step
## Negative Constraints
- None
EOF
set +e
VS_NO_USE_WHEN=$(bash "$VALIDATOR_SUITE" "$NO_USE_WHEN" 2>&1)
set -e
if [[ "$VS_NO_USE_WHEN" == *"description must contain 'Use when"* ]]; then
  pass "validate-suite: rejects skill missing 'Use when ...' in description"
else
  fail "validate-suite: allowed description missing 'Use when'"
fi

# 19. Skill missing triggers in frontmatter
NO_TRIGGERS="$TMP_SANDBOX/no-triggers.md"
cat > "$NO_TRIGGERS" << 'EOF'
---
name: no-triggers
description: Missing triggers section. Use when testing.
---
# Instructions
1. Step
## Negative Constraints
- None
EOF
set +e
VS_NO_TRIG=$(bash "$VALIDATOR_SUITE" "$NO_TRIGGERS" 2>&1)
set -e
if [[ "$VS_NO_TRIG" == *"missing 'triggers:' in frontmatter"* ]]; then
  pass "validate-suite: rejects skill with missing triggers"
else
  fail "validate-suite: allowed missing triggers"
fi

# 20. Skill body exceeding 600 lines
HUGE_SKILL="$TMP_SANDBOX/huge-skill.md"
cat > "$HUGE_SKILL" << 'EOF'
---
name: huge-skill
description: Skill that exceeds 600 lines. Use when testing.
triggers:
  - test
---
# Instructions
EOF
for i in $(seq 1 610); do
  echo "Line $i of instructions content" >> "$HUGE_SKILL"
done
cat >> "$HUGE_SKILL" << 'EOF'
## Negative Constraints
- None
EOF
set +e
VS_HUGE=$(bash "$VALIDATOR_SUITE" "$HUGE_SKILL" 2>&1)
set -e
if [[ "$VS_HUGE" == *"exceeds 600 cap"* ]]; then
  pass "validate-suite: rejects skill whose body exceeds 600 line limit"
else
  fail "validate-suite: allowed skill exceeding 600 lines"
fi

# 21. Skill missing Negative Constraints or Safety section
NO_NEG="$TMP_SANDBOX/no-neg-constraints.md"
cat > "$NO_NEG" << 'EOF'
---
name: no-neg-constraints
description: Missing negative constraints. Use when testing.
triggers:
  - test
---
# Instructions
1. Step 1
EOF
set +e
VS_NO_NEG=$(bash "$VALIDATOR_SUITE" "$NO_NEG" 2>&1)
set -e
if [[ "$VS_NO_NEG" == *"missing Negative Constraints or Safety section"* ]]; then
  pass "validate-suite: rejects skill missing Negative Constraints or Safety section"
else
  fail "validate-suite: allowed skill missing negative constraints"
fi

# 22. Skill missing Instructions section
NO_INSTR="$TMP_SANDBOX/no-instructions.md"
cat > "$NO_INSTR" << 'EOF'
---
name: no-instructions
description: Missing instructions section. Use when testing.
triggers:
  - test
---
# Overview
Some overview text without instructions heading.

## Negative Constraints
- None
EOF
set +e
VS_NO_INSTR=$(bash "$VALIDATOR_SUITE" "$NO_INSTR" 2>&1)
set -e
if [[ "$VS_NO_INSTR" == *"missing Instructions or Workflow section"* ]]; then
  pass "validate-suite: rejects skill missing Instructions or Workflow section"
else
  fail "validate-suite: allowed skill missing instructions"
fi

# 23. validate-suite on directory target and non-existent target
TARGET_DIR="$TMP_SANDBOX/test_skills_dir"
mkdir -p "$TARGET_DIR"
cp "$VALID_SKILL" "$TARGET_DIR/"
set +e
VS_DIR_OUT=$(bash "$VALIDATOR_SUITE" "$TARGET_DIR" 2>&1)
VS_DIR_CODE=$?
set -e
if [[ $VS_DIR_CODE -eq 0 ]] && [[ "$VS_DIR_OUT" == *"0 failed"* ]]; then
  pass "validate-suite: directory target traverses and validates all markdown skills"
else
  fail "validate-suite: directory target failed (code: $VS_DIR_CODE)"
fi

set +e
VS_NOT_FOUND=$(bash "$VALIDATOR_SUITE" "$TMP_SANDBOX/non_existent_path_xyz" 2>&1)
VS_NF_CODE=$?
set -e
if [[ $VS_NF_CODE -ne 0 ]] && [[ "$VS_NOT_FOUND" == *"target not found"* ]]; then
  pass "validate-suite: rejects non-existent target with explicit error"
else
  fail "validate-suite: allowed non-existent target (code: $VS_NF_CODE)"
fi

# ==============================================================================
# SECTION 4: Filesystem Chaos & Permission Denial
# ==============================================================================

# 24. Read-only project directory handled safely by ai-suite enable
READONLY_DIR="$TMP_SANDBOX/readonly_project"
mkdir -p "$READONLY_DIR"
touch "$READONLY_DIR/existing_file.txt"
chmod 500 "$READONLY_DIR"

set +e
RO_OUT=$(bash "$SUITE_CLI" enable --agent claude --scope project --project "$READONLY_DIR" 2>&1)
RO_CODE=$?
set -e
chmod 700 "$READONLY_DIR"

if [[ $RO_CODE -ne 0 ]]; then
  pass "chaos: ai-suite enable fails safely when target directory is read-only"
else
  fail "chaos: ai-suite enable did not fail on read-only directory"
fi

total=$((PASS+FAIL))
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[module-6-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[module-6-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
