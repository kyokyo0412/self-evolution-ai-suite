#!/usr/bin/env bash
set -euo pipefail

# Test script for isolation feature

PASS=0
FAIL=0

pass() { PASS=$((PASS+1)); echo "PASS: $*"; }
fail() { FAIL=$((FAIL+1)); echo "FAIL: $*"; }

# 1. Test ai-suite publish excludes domains
echo "Testing ai-suite publish..."
bash ai-suite publish >/dev/null
if tar -tzf ai-suite-package.tar.gz | grep -q "layer3-registry/domains"; then
  fail "ai-suite publish included domains"
else
  pass "ai-suite publish excluded domains"
fi

# 2. Test absorb-capability.md mentions merging into BOTH
echo "Testing absorb-capability.md..."
if grep -q "MUST ONLY merge the new capabilities into the developing AI suite source code" .ai-suite/layer4-evolutionary/merging/absorb-capability.md; then
  fail "absorb-capability.md still says MUST ONLY merge into .ai-suite/"
else
  pass "absorb-capability.md updated"
fi

if grep -q "MUST NOT impact or modify any items in the Host agent configuration" .ai-suite/layer4-evolutionary/merging/absorb-capability.md; then
  fail "absorb-capability.md still says MUST NOT impact Host agent configuration"
else
  pass "absorb-capability.md updated Host agent configuration constraint"
fi

# 3. Test ai-suite evolve runs ai-suite enable after collect
echo "Testing ai-suite evolve..."
if grep -q "Updating the local Augmented Agent" .ai-suite/cli/evolve.sh; then
  pass "ai-suite evolve runs ai-suite enable after collect"
else
  fail "ai-suite evolve does not run ai-suite enable after collect"
fi

# 4. Test evolve-collect.md mentions updating Augmented Agent
echo "Testing evolve-collect.md..."
if grep -q "integrated into the AI suite being developed" .ai-suite/layer4-evolutionary/merging/evolve-collect.md; then
  pass "evolve-collect.md updated"
else
  fail "evolve-collect.md not updated"
fi

echo "Total PASS: $PASS, FAIL: $FAIL"
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
exit 0
