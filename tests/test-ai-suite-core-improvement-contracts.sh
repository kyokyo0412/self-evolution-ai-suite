#!/usr/bin/env bash
# tests/test-ai-suite-core-improvement-contracts.sh -- Contract tests for AI suite core improvements
set -euo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUITE_DIR="$SUITE_ROOT/.ai-suite"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

echo "=== Phase 2 Architectural Contract Tests: Core Suite Functions ==="

# 1. Multi-Agent Adapters Interface Contract
for agent in cursor claude opencode continue roo-code codex; do
  adapter="$SUITE_DIR/layer1-abstraction/agents/$agent/adapter.sh"
  if [[ -f "$adapter" ]]; then
    if grep -q "agent_install_project" "$adapter" && \
       grep -q "agent_install_global" "$adapter" && \
       grep -q "agent_uninstall_project" "$adapter" && \
       grep -q "agent_uninstall_global" "$adapter"; then
      pass "Adapter contract: $agent implements standard interface"
    else
      fail "Adapter contract: $agent missing standard interface functions"
    fi
  else
    fail "Adapter contract: missing adapter for $agent"
  fi
done

# 2. Publish Script Contract
PUBLISH_CLI="$SUITE_DIR/cli/publish.sh"
if [[ -f "$PUBLISH_CLI" && -x "$PUBLISH_CLI" ]]; then
  pass "Publish contract: publish.sh exists and is executable"
else
  fail "Publish contract: publish.sh missing or not executable"
fi

# 3. Evolve Script Contract
EVOLVE_CLI="$SUITE_DIR/cli/evolve.sh"
if [[ -f "$EVOLVE_CLI" ]]; then
  if grep -q "do_collect" "$EVOLVE_CLI" && grep -q "do_push" "$EVOLVE_CLI"; then
    pass "Evolve contract: evolve.sh implements do_collect and do_push"
  else
    fail "Evolve contract: evolve.sh missing do_collect or do_push"
  fi
else
  fail "Evolve contract: missing evolve.sh"
fi

# 4. Absorb and Integrate Skills Contract
ABSORB_SKILL="$SUITE_DIR/layer4-evolutionary/merging/absorb-capability.md"
INTEGRATE_SKILL="$SUITE_DIR/layer4-evolutionary/merging/integrate-capability.md"
if [[ -f "$ABSORB_SKILL" && -f "$INTEGRATE_SKILL" ]]; then
  pass "Skills contract: absorb-capability.md and integrate-capability.md exist"
else
  fail "Skills contract: missing absorb or integrate skill definition"
fi

# 5. Core 4-Layer Hierarchy Contract
for layer in layer1-abstraction layer2-cognitive layer3-registry layer4-evolutionary; do
  if [[ -d "$SUITE_DIR/$layer" ]]; then
    pass "Hierarchy contract: $layer exists"
  else
    fail "Hierarchy contract: missing $layer"
  fi
done

total=$((PASS+FAIL))
echo ""
if [[ "$FAIL" -eq 0 ]]; then
  printf '\033[32m[contract-test] %d/%d passed\033[0m\n' "$PASS" "$total"
  exit 0
else
  printf '\033[31m[contract-test] %d passed, %d FAILED / %d total\033[0m\n' "$PASS" "$FAIL" "$total" >&2
  exit 1
fi
