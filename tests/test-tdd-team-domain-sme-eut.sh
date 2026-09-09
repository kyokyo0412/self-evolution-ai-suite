#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-domain-sme-eut.sh
# End-to-End User Acceptance Test for Dynamic Domain SME integration in tdd-team skill

echo "Running EUT for Dynamic Domain SME in tdd-team skill..."

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

validate_domain_sme_eut() {
  local file="$1"
  echo "Evaluating Dynamic Domain SME EUT on $file..."

  # 1. Roster verification
  grep -qi "Principal Subject Matter Expert (SME) & Domain Architect (Dynamically Instantiated)" "$file"
  grep -qi "eleven-role" "$file"

  # 2. Phase 1.1 Domain Classification & Risk Profiling
  grep -qi "Domain Classification & Risk Profiling" "$file"
  grep -qi "Domain Category & Standards Mapping" "$file"
  grep -qi "Domain Specific Failure Modes" "$file"
  grep -qi "Domain Non-Functional Requirements" "$file"

  # 3. Phase 1.3 & 1.5 BDD / SDET test conversion
  grep -qi "convert.*domain failure modes.*executable" "$file" || grep -qi "domain failure modes into executable" "$file"

  # 4. Reviewer Gate veto authority
  grep -qi "Dynamic SME determines that domain-specific compliance" "$file" || grep -qi "protocol bounds were omitted" "$file"

  # 5. Domain Context Matrix
  grep -qi "Domain Context Matrix" "$file"

  # 6. Backward compatibility with other 10 roles
  grep -qi "Staff/Principal PM" "$file"
  grep -qi "Distinguished AI Expert" "$file"
  grep -qi "Fellow/Principal Engineer" "$file"
  grep -qi "Principal Systems Architect" "$file"
  grep -qi "Principal UX/UI Product Designer" "$file"
  grep -qi "Principal Frontend & Mobile Solutions Architect" "$file"
  grep -qi "Principal AI-Augmented Workflow" "$file"
  grep -qi "Senior Principal SDET" "$file"
  grep -qi "Staff Systems Developer" "$file"
  grep -qi "Senior Lead Technical Writer" "$file"

  echo "EUT evaluation passed for $file"
}

validate_domain_sme_eut "$TARGET_SOURCE"
if [ -f "$TARGET_CURSOR" ]; then
  validate_domain_sme_eut "$TARGET_CURSOR"
fi
if [ -f "$TARGET_CODEX" ]; then
  validate_domain_sme_eut "$TARGET_CODEX"
fi

echo "All Dynamic Domain SME EUT checks passed successfully!"
exit 0
