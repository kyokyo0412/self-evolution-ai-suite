#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-domain-sme-contracts.sh
# Contract validation for Dynamic Domain SME & Domain Risk Profiling in tdd-team skill

check_domain_sme_contracts() {
  local file="$1"
  if [ ! -f "$file" ]; then
    echo "FAIL: Target file $file does not exist."
    return 1
  fi

  echo "Validating Dynamic Domain SME contracts in: $file"

  # 1. Team Roster: 11-role team & Dynamic SME Role
  echo "  Checking 11-role team roster..."
  if ! grep -qi "eleven-role" "$file"; then
    echo "  FAIL: 'eleven-role' team roster definition missing in $file"
    return 1
  fi

  echo "  Checking Principal SME & Domain Architect in Roster..."
  if ! grep -qi "Principal Subject Matter Expert (SME) & Domain Architect (Dynamically Instantiated)" "$file"; then
    echo "  FAIL: Dynamic SME & Domain Architect role missing in $file"
    return 1
  fi

  # 2. Phase 1.1 Domain Classification & Risk Profiling
  echo "  Checking Phase 1.1 Domain Classification & Risk Profiling..."
  if ! grep -qi "Domain Classification & Risk Profiling" "$file"; then
    echo "  FAIL: 'Domain Classification & Risk Profiling' step missing in $file"
    return 1
  fi

  if ! grep -qi "Domain Category & Standards Mapping" "$file"; then
    echo "  FAIL: 'Domain Category & Standards Mapping' missing in $file"
    return 1
  fi

  if ! grep -qi "Domain Specific Failure Modes" "$file"; then
    echo "  FAIL: 'Domain Specific Failure Modes' missing in $file"
    return 1
  fi

  if ! grep -qi "Domain Non-Functional Requirements" "$file"; then
    echo "  FAIL: 'Domain Non-Functional Requirements' missing in $file"
    return 1
  fi

  # 3. Phase 1.3 & 1.5 BDD / SDET Domain Failure Modes Conversion
  echo "  Checking Phase 1.3 BDD conversion of failure modes..."
  if ! grep -qi "domain failure modes into executable.*scenarios\|domain failure modes into executable" "$file"; then
    echo "  FAIL: Phase 1.3 failure mode conversion to executable scenarios missing in $file"
    return 1
  fi

  echo "  Checking Phase 1.5 SDET conversion of failure modes..."
  if ! grep -qi "domain failure modes into executable test\|convert.*domain failure modes" "$file"; then
    echo "  FAIL: Phase 1.5 SDET failure mode conversion missing in $file"
    return 1
  fi

  # 4. Phase 1.4 & 1.6 Review Gates
  echo "  Checking Phase 1.4 Review Gate rejection criteria..."
  if ! grep -qi "Dynamic SME determines that domain-specific compliance, safety, or protocol bounds were omitted" "$file"; then
    echo "  FAIL: Phase 1.4 Review Gate domain rejection criteria missing in $file"
    return 1
  fi

  echo "  Checking Phase 1.6 Review Gate rejection criteria..."
  if ! grep -qi "Dynamic SME determines that domain failure modes, compliance bounds, or safety/protocol bounds were omitted" "$file"; then
    echo "  FAIL: Phase 1.6 Review Gate domain rejection criteria missing in $file"
    return 1
  fi

  # 5. Execution Directives (Domain Context Matrix)
  echo "  Checking Execution Directives (Domain Context Matrix)..."
  if ! grep -qi "Domain Context Matrix" "$file"; then
    echo "  FAIL: 'Domain Context Matrix' execution instruction missing in $file"
    return 1
  fi

  # 6. Order-2 Synergy: Phase 2, Phase 3, Phase 5 SME Integration
  echo "  Checking Phase 2.1 & 2.2 Domain Architecture synergy..."
  if ! grep -qi "Dynamic SME.*protocol\|regulatory.*boundaries\|Domain Protocol & Regulatory Conformance" "$file"; then
    echo "  FAIL: Phase 2 Domain Architecture synergy missing in $file"
    return 1
  fi

  echo "  Checking Phase 3.5 Domain Integrity review..."
  if ! grep -qi "Domain Integrity & Regulatory Boundary Safety\|Domain Integrity" "$file"; then
    echo "  FAIL: Phase 3.5 Domain Integrity line-level review missing in $file"
    return 1
  fi

  echo "  Checking Phase 5 Domain Traceability Matrix..."
  if ! grep -qi "Domain Compliance & Regulatory Traceability Matrix" "$file"; then
    echo "  FAIL: Phase 5 Domain Compliance Traceability Matrix missing in $file"
    return 1
  fi

  # 7. Order-2 Exemplar & Negative Veto Constraint
  echo "  Checking Multi-Domain Exemplar coverage in Roster..."
  for domain in "Telecom" "HealthTech" "High-Frequency Trading" "Aerospace" "FinTech" "IoT" "Automotive"; do
    if ! grep -qi "$domain" "$file"; then
      echo "  FAIL: Multi-domain exemplar '$domain' missing in $file"
      return 1
    fi
  done

  echo "  Checking Negative Constraint against proceeding without SME Domain Risk Profiling..."
  if ! grep -qi "Do not bypass Domain Classification & Risk Profiling\|Do not proceed to Phase 1.2.*without.*Domain Context Matrix" "$file"; then
    echo "  FAIL: Negative constraint for Domain Profiling / Domain Context Matrix missing in $file"
    return 1
  fi

  echo "  PASS: All Dynamic Domain SME contracts verified for $file"
  return 0
}

TARGET_SOURCE=".ai-suite/layer3-registry/core/tdd-team.md"
TARGET_CURSOR="$HOME/.cursor/skills/tdd-team/SKILL.md"
TARGET_CODEX="$HOME/.codex/skills/tdd-team/SKILL.md"

if [ "$#" -gt 0 ]; then
  check_domain_sme_contracts "$1"
  exit $?
fi

PASS_COUNT=0
FAIL_COUNT=0

if check_domain_sme_contracts "$TARGET_SOURCE"; then
  PASS_COUNT=$((PASS_COUNT + 1))
else
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

if [ -f "$TARGET_CURSOR" ]; then
  if check_domain_sme_contracts "$TARGET_CURSOR"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ -f "$TARGET_CODEX" ]; then
  if check_domain_sme_contracts "$TARGET_CODEX"; then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "OVERALL FAIL: $FAIL_COUNT file(s) failed Dynamic Domain SME contract verification."
  exit 1
fi

echo "OVERALL SUCCESS: All $PASS_COUNT checked files passed Dynamic Domain SME contract verification."
exit 0
