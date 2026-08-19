#!/usr/bin/env bash
# test-remote-suite-contracts.sh — Phase 2 contract tests for remote-suite.md.
# Run from workspace root: bash tests/test-remote-suite-contracts.sh

set -uo pipefail

SUITE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$SUITE_ROOT/.ai-suite/layer4-evolutionary/merging/remote-suite.md"

PASS=0; FAIL=0
_red() { printf '\033[31m'; }; _grn() { printf '\033[32m'; }; _off() { printf '\033[0m'; }
pass() { PASS=$((PASS+1)); printf '  %sPASS%s  %s\n' "$(_grn)" "$(_off)" "$*"; }
fail() { FAIL=$((FAIL+1)); printf '  %sFAIL%s  %s\n' "$(_red)" "$(_off)" "$*" >&2; }

file_contains() {
  local label="$1" needle="$2"
  if grep -qF -- "$needle" "$SKILL" 2>/dev/null; then pass "$label"
  else fail "$label — skill does not contain: $needle"; fi
}
file_matches() {
  local label="$1" pat="$2"
  if grep -qE -- "$pat" "$SKILL" 2>/dev/null; then pass "$label"
  else fail "$label — skill does not match pattern: $pat"; fi
}
# shellcheck disable=SC2329  # used for potential future negative checks
file_not_matches() {
  local label="$1" pat="$2"
  if ! grep -qiE -- "$pat" "$SKILL" 2>/dev/null; then pass "$label"
  else fail "$label — skill unexpectedly matches: $pat"; fi
}

echo "=== Phase 2 Contract Tests: remote-suite.md ==="
echo ""

# ── P1/P2: File exists and validates ────────────────────────────────────────
echo "--- P: placement ---"
if [[ -f "$SKILL" ]]; then pass "P1: skill file exists at $SKILL"
else fail "P1: skill file not found at $SKILL"; fi

if [[ -f "$SKILL" ]]; then
  val_out=$(bash "$SUITE_ROOT/.ai-suite/layer4-evolutionary/validation/validate-suite.sh" "$SKILL" 2>&1)
  val_exit=$?
  if [[ "$val_exit" -eq 0 ]]; then pass "P2: validate-suite.sh passes"
  else fail "P2: validate-suite.sh FAILED: $val_out"; fi
fi

# ── F: Frontmatter ───────────────────────────────────────────────────────────
echo ""
echo "--- F: frontmatter ---"
file_contains "F1: name is remote-suite"    "name: remote-suite"
file_contains "F2: description has Use when" "Use when"

# ── F3: Triggers ─────────────────────────────────────────────────────────────
echo ""
echo "--- F3: trigger phrases ---"
file_contains "F3a: trigger install ai-suite"         "install ai-suite"
file_contains "F3b: trigger remove ai-suite"          "remove ai-suite"
file_contains "F3c: trigger check ai-suite status"    "check ai-suite"
file_contains "F3d: trigger deploy ai-suite"          "deploy ai-suite"
file_contains "F3e: trigger remote ai-suite"          "remote ai-suite"

# ── I: Intent mapping — commands present in skill body ───────────────────────
echo ""
echo "--- I: intent-to-command mapping ---"
file_contains "I1a: ai-suite enable --scope remote" "ai-suite enable --scope remote"
file_contains "I1b: ai-suite evolve collect"        "ai-suite evolve collect"
file_contains "I1c: ai-suite evolve push"           "ai-suite evolve push"
file_contains "I1d: ai-suite disable --scope remote" "ai-suite disable --scope remote"
file_matches  "I1e: SSH status probe"               "(ssh|SSH).*status|status.*ssh"

# ── CB: Command building ──────────────────────────────────────────────────────
echo ""
echo "--- CB: command-building rules ---"
file_contains  "CB1: extracts --host"        "--host"
file_contains  "CB2: --agent flag mentioned" "--agent"
file_contains  "CB3: --domain flag mentioned" "--domain"
file_contains  "CB4: --remote-scope project" "--remote-scope project"
file_contains  "CB5: --remote-path mentioned" "--remote-path"
file_matches   "CB6: dry-run handling"       "(dry.run|preview)"
file_matches   "CB7: multiple hosts"         "(multiple|multi.*host|per.*host|each.*host)"

# ── MH: Missing host ──────────────────────────────────────────────────────────
echo ""
echo "--- MH: missing-host rule ---"
file_matches "MH1: asks for host if missing"  "(ask|which.*host|Which.*host|HOST.*required|host.*required)"
file_matches "MH2: question format user@hostname" "(user@hostname|USER@HOST)"

# ── SR: Safety rules ─────────────────────────────────────────────────────────
echo ""
echo "--- SR: safety ---"
file_matches "SR1: production warning"       "(prod|production)"
file_matches "SR2: no auto-commit"           "(auto.commit|never.*commit|git.*commands)"
file_matches "SR3: missing script preflight" "(missing|not found|preflight|check.*exist)"

# ── S: Structural sections ────────────────────────────────────────────────────
echo ""
echo "--- S: structural sections ---"
file_matches "S1: Operations section" "^##.*[Oo]peration"
file_matches "S2: Examples section"   "^##.*[Ee]xample"
file_matches "S3: Safety section"     "^##.*[Ss]afety"
file_matches "S4: Negative constraints / Must NOT" "^#.*[Nn]egative|^#.*Must NOT|^#.*NEVER"

# ── Body line count ───────────────────────────────────────────────────────────
echo ""
echo "--- V: validator (body length) ---"
if [[ -f "$SKILL" ]]; then
  total_lines=$(wc -l < "$SKILL" | tr -d ' ')
  if [[ "$total_lines" -le 600 ]]; then pass "V: skill body <= 600 lines (actual: $total_lines)"
  else fail "V: skill too long ($total_lines lines, max 600)"; fi
fi

# ── Summary ───────────────────────────────────────────────────────────────────
printf '\n'
total=$((PASS+FAIL))
if [[ "$FAIL" -eq 0 ]]; then
  printf '%s[contract-test] %d/%d passed%s\n' "$(_grn)" "$PASS" "$total" "$(_off)"
  exit 0
else
  printf '%s[contract-test] %d passed, %d FAILED / %d total%s\n' \
    "$(_grn)" "$PASS" "$FAIL" "$total" "$(_off)" >&2
  exit 1
fi
