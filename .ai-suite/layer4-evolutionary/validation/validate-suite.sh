#!/usr/bin/env bash
# validate-suite.sh — Lint frontmatter of .ai-suite/ skill files.
#
# Scans all three skill tiers when called with no arguments:
#   .ai-suite/layer3-registry/core/
#   .ai-suite/layer1-abstraction/agents/cursor/skills/
#
# Rules enforced on every *.md in skill directories:
#   - First non-empty line is "---" (YAML frontmatter open).
#   - Closing "---" appears within the first 20 lines.
#   - "name:" present, matches ^[a-z0-9-]+$, length 1..64, equals file basename.
#   - "description:" present, length 1..1024 chars, contains "Use when".
#   - body (after frontmatter) is <= 600 lines.
#
# Usage:
#   bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh                    # lint all skill tiers
#   bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh path/to/dir        # lint a single dir
#   bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh path/to/file.md   # lint a single file

set -uo pipefail
export LC_ALL=C

ERRORS=0
PASSES=0

if [[ -t 1 ]]; then
  C_RED=$'\033[31m'
  C_GRN=$'\033[32m'
  C_OFF=$'\033[0m'
else
  C_RED=''
  C_GRN=''
  C_OFF=''
fi

pass() { PASSES=$((PASSES + 1)); printf '  %sPASS%s  %s\n' "$C_GRN" "$C_OFF" "$*"; }
fail() { ERRORS=$((ERRORS + 1)); printf '  %sFAIL%s  %s\n' "$C_RED" "$C_OFF" "$*" >&2; }

validate_file() {
  local file="$1"
  local rel="${file#./}"
  local base="${file##*/}"
  base="${base%.md}"

  local in_fm=0
  local line_num=0
  local fm_close_line=0
  local name=""
  local desc=""
  local triggers=""
  local body_lines=0
  local has_neg_constraints=0
  local has_instructions=0

  shopt -s nocasematch

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))
    if [[ $line_num -eq 1 ]]; then
      if [[ "$line" != "---" ]]; then
        fail "$rel: first line must be --- (got '$line')"
        shopt -u nocasematch
        return
      fi
      in_fm=1
      continue
    fi

    if [[ $in_fm -eq 1 ]]; then
      if [[ "$line" == "---" ]]; then
        in_fm=0
        fm_close_line=$line_num
        continue
      fi
      if [[ "$line" =~ ^name:[[:space:]]*(.*)$ ]]; then
        name="${BASH_REMATCH[1]}"
        # Strip trailing carriage returns if any
        name="${name%$'\r'}"
      elif [[ "$line" =~ ^description:[[:space:]]*(.*)$ ]]; then
        desc="${BASH_REMATCH[1]}"
        desc="${desc%$'\r'}"
        desc="${desc%\"}"
        desc="${desc#\"}"
      elif [[ "$line" =~ ^triggers: ]]; then
        triggers="yes"
      fi
    else
      body_lines=$((body_lines + 1))
      if [[ "$line" =~ ^#+.*(negative[[:space:]]constraints|safety[[:space:]]rules|safety[[:space:]]constraints|rules[[:space:]]of[[:space:]]engagement) ]]; then
        has_neg_constraints=1
      elif [[ "$line" =~ ^#+.*(instructions|workflow|role|context|artifact[[:space:]]catalog|operational[[:space:]]loop|steps|usage|procedure|operations|step-by-step[[:space:]]execution|protocol|execution) ]]; then
        has_instructions=1
      fi
    fi
  done < "$file"

  shopt -u nocasematch

  if [[ $fm_close_line -eq 0 || $fm_close_line -gt 20 ]]; then
    fail "$rel: closing --- not found within first 20 lines"
    return
  fi

  if [[ -z "$name" ]]; then
    fail "$rel: missing 'name:' in frontmatter"
  elif [[ ! "$name" =~ ^[a-z0-9-]+$ ]]; then
    fail "$rel: name '$name' must match ^[a-z0-9-]+$"
  elif [[ ${#name} -gt 64 ]]; then
    fail "$rel: name length ${#name} > 64"
  elif [[ "$name" != "$base" ]]; then
    fail "$rel: name '$name' must equal filename basename '$base'"
  else
    pass "$rel: name='$name' valid"
  fi

  if [[ -z "$desc" ]]; then
    fail "$rel: missing 'description:' in frontmatter"
  elif [[ ${#desc} -gt 1024 ]]; then
    fail "$rel: description length ${#desc} > 1024"
  elif [[ "$desc" != *"Use when"* ]]; then
    fail "$rel: description must contain 'Use when ...' so the agent knows when to invoke"
  else
    pass "$rel: description length=${#desc}, contains 'Use when'"
  fi

  if [[ -z "$triggers" ]]; then
    fail "$rel: missing 'triggers:' in frontmatter"
  else
    pass "$rel: 'triggers:' present"
  fi

  if [[ "$body_lines" -le 600 ]]; then
    pass "$rel: body=${body_lines} lines (<= 600)"
  else
    fail "$rel: body=${body_lines} lines exceeds 600 cap"
  fi

  if [[ $has_neg_constraints -eq 0 ]]; then
    fail "$rel: missing Negative Constraints or Safety section"
  else
    pass "$rel: Negative Constraints or Safety section present"
  fi

  if [[ $has_instructions -eq 0 ]]; then
    fail "$rel: missing Instructions or Workflow section"
  else
    pass "$rel: Instructions or Workflow section present"
  fi
}

validate_target() {
  local target="$1"
  if [[ -f "$target" ]]; then
    validate_file "$target"
  elif [[ -d "$target" ]]; then
    while IFS= read -r -d '' f; do
      validate_file "$f"
    done < <(find "$target" -maxdepth 2 -name '*.md' -type f -print0)
  else
    fail "target not found: $target"
  fi
}

if [[ $# -eq 0 ]]; then
  HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  SUITE_ROOT="$(cd "$HERE/../.." && pwd)"

  # Check for duplicate skill names across all tiers
  dup_skills=$(find "$SUITE_ROOT/layer3-registry/core" "$SUITE_ROOT/layer1-abstraction/agents"/*/skills "$SUITE_ROOT"/layer3-registry/domains/*/skills -maxdepth 1 -name '*.md' -type f 2>/dev/null | awk -F/ '{print $NF}' | sort | uniq -d)
  if [[ -n "$dup_skills" ]]; then
    for dup in $dup_skills; do
      fail "Duplicate skill name found across tiers: ${dup%.md}"
    done
  else
    pass "No duplicate skill names across tiers"
  fi

  validate_target "$SUITE_ROOT/layer3-registry/core"
  validate_target "$SUITE_ROOT/layer1-abstraction/agents/cursor/skills"
  if [[ -d "$SUITE_ROOT/layer3-registry/domains" ]]; then
    for domain in "$SUITE_ROOT"/layer3-registry/domains/*; do
      if [[ -d "$domain/skills" ]]; then
        validate_target "$domain/skills"
      fi
    done
  fi
  if [[ -d "$SUITE_ROOT/layer4-evolutionary/merging" ]]; then
    validate_target "$SUITE_ROOT/layer4-evolutionary/merging"
  fi
else
  for t in "$@"; do
    validate_target "$t"
  done
fi

printf '\n'
if [[ "$ERRORS" -eq 0 ]]; then
  printf '%s[validate-suite] %d checks passed, 0 failed%s\n' "${C_GRN}" "$PASSES" "${C_OFF}"
  exit 0
else
  printf '%s[validate-suite] %d passed, %d FAILED%s\n' "${C_RED}" "$PASSES" "$ERRORS" "${C_OFF}" >&2
  exit 1
fi
