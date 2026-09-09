#!/usr/bin/env bash
set -euo pipefail

# test-tdd-team-developer-runbook-contracts.sh
# Validates that README.md and documentation suites provide complete
# developer guidance, operational runbooks, and domain recipes for tdd-team.

README_FILE="README.md"
if [ ! -f "$README_FILE" ]; then
  echo "FAIL: $README_FILE does not exist."
  exit 1
fi

echo "Validating Dynamic Domain SME Developer Guidance & Operational Runbook contracts..."

echo "  Checking Operational Runbook header..."
if ! grep -qi "Dynamic Domain SME Operational Runbook & Developer Guide" "$README_FILE"; then
  echo "  FAIL: 'Dynamic Domain SME Operational Runbook & Developer Guide' header missing in $README_FILE"
  exit 1
fi

echo "  Checking Domain Discovery & Profiling Lifecycle documentation..."
if ! grep -qi "Domain Classification & Risk Profiling.*Workflow" "$README_FILE" && ! grep -qi "Domain Profiling & SME Lifecycle" "$README_FILE"; then
  echo "  FAIL: Domain Profiling Lifecycle section missing in $README_FILE"
  exit 1
fi

echo "  Checking Multi-Domain Recipe Matrix (Telecom, HealthTech, FinTech, Aerospace, IoT, Automotive)..."
for domain in "Telecom" "HealthTech" "FinTech" "Aerospace" "IoT" "Automotive"; do
  if ! grep -qi "$domain" "$README_FILE"; then
    echo "  FAIL: Multi-domain recipe entry for '$domain' missing in $README_FILE"
    exit 1
  fi
done

echo "  Checking Domain Failure Modes to BDD / SDET translation runbook..."
if ! grep -qi "Executable Test Translation Runbook" "$README_FILE" && ! grep -qi "Translating Domain Failure Modes to Executable Tests" "$README_FILE"; then
  echo "  FAIL: Domain failure mode to executable test translation runbook missing in $README_FILE"
  exit 1
fi

echo "  Checking Domain Adversarial Chaos Injection & Fault Injection Recipes..."
if ! grep -qi "Domain Chaos Injection.*Runbook" "$README_FILE" && ! grep -qi "Adversarial Chaos.*Recipes" "$README_FILE"; then
  echo "  FAIL: Domain chaos injection / fault injection recipes missing in $README_FILE"
  exit 1
fi

echo "  Checking 1E-Class Safety & Deterministic Bounds Verification Guidance..."
if ! grep -qi "1E-Class Safety & Deterministic Resource Runbook" "$README_FILE" && ! grep -qi "1E-Class Deterministic Bounds Verification" "$README_FILE"; then
  echo "  FAIL: 1E-Class Safety & Deterministic Resource runbook missing in $README_FILE"
  exit 1
fi

echo "  Checking Domain Compliance & Regulatory Traceability Matrix Guidance..."
if ! grep -qi "Domain Compliance & Regulatory Traceability Matrix" "$README_FILE"; then
  echo "  FAIL: Domain Compliance & Regulatory Traceability Matrix guidance missing in $README_FILE"
  exit 1
fi

echo "PASS: All Dynamic Domain SME Developer Guidance & Operational Runbook contracts verified in $README_FILE."
exit 0
