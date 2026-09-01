#!/usr/bin/env bash
# test-local-suite-sandbox-fallback.sh -- Acceptance test for the
# "Restricted Execution Environment (Sandbox) Fallback" section added to
# the local-suite skill (reflection evolution).
#
# Verifies:
#   1. The skill file exists with valid frontmatter (name/description/"Use when").
#   2. The sandbox fallback section is present with all 5 fallback steps.
#   3. All three sandbox failure signatures are documented.
#   4. Step-by-step execution references the fallback (discoverability).
#   5. The file is ASCII-only (repo invariant, commit "use ASCII code for all files").

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SKILL="$ROOT/layer3-registry/core/local-suite.md"

FAILURES=0
check() { # check <description> <command...>
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    printf 'PASS  %s\n' "$desc"
  else
    printf 'FAIL  %s\n' "$desc"
    FAILURES=$((FAILURES + 1))
  fi
}

check "skill file exists" test -f "$SKILL"
check "frontmatter name matches file" bash -c "grep -q '^name: local-suite$' '$SKILL'"
check "description contains 'Use when'" bash -c "grep '^description:' '$SKILL' | grep -q 'Use when'"
check "fallback section present" grep -q "Restricted Execution Environment (Sandbox) Fallback" "$SKILL"
check "signature: cp Operation not permitted" grep -q "Operation not permitted" "$SKILL"
check "signature: ssh connect blocked" grep -q "ssh: connect to host" "$SKILL"
check "signature: harness rejection" grep -q "Rejected(" "$SKILL"
check "step: stop mutating" grep -q "Stop mutating" "$SKILL"
check "step: verify existing deployment" grep -q "Verify the existing deployment" "$SKILL"
check "step: confirm no damage" grep -q "Confirm no damage" "$SKILL"
check "step: hand off exact commands" grep -q "Hand off exact commands" "$SKILL"
check "step: report the delta" grep -q "Report the delta" "$SKILL"
check "step-by-step references fallback" grep -q "Section 4 fallback" "$SKILL"
check "file is ASCII-only" bash -c "! LC_ALL=C grep -q '[^ -~	]' '$SKILL'"

if [[ "$FAILURES" -eq 0 ]]; then
  printf '\nAll sandbox-fallback checks passed.\n'
  exit 0
else
  printf '\n%d check(s) failed.\n' "$FAILURES"
  exit 1
fi
