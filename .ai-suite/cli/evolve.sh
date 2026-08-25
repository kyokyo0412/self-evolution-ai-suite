#!/usr/bin/env bash
# ai-suite evolve - Collect remote ai-suite evolutions into the local git
# repo, and push the updated suite back to remote SSH hosts.
#
# Sub-commands:
#   collect   Pull .ai-suite/ changes from one or more remote hosts.
#   push      Push the local (evolved) .ai-suite/ to one or more remote hosts.
#
# Usage:
#   ai-suite evolve collect --host USER@HOST [--host USER@HOST2 ...]
#                           [--remote-path PATH] [--dry-run]
#
#   ai-suite evolve push    --host USER@HOST [--host USER@HOST2 ...]
#                           [--remote-path PATH]
#                           [--remote-scope global|project]
#                           [--dry-run]
#
# Exit codes:
#   0   success / no changes / dry-run completed
#   1   bad invocation (missing required arg or unknown flag)
#   2   suite source files not found next to this script
#   3   all hosts failed (push)
#  10   partial failure (push, at least one host failed)

set -uo pipefail

# -- Locate suite root ---------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SUITE_ROOT="$SCRIPT_DIR"
SUITE_DIR="$SUITE_ROOT/.ai-suite"
# -- Core Library -------------------------------------------------------------
CORE_LIB="$SUITE_DIR/layer2-cognitive/memory/core.sh"
if [[ ! -f "$CORE_LIB" ]]; then
  printf '[evolve] ERROR: core.sh not found: %s\n' "$CORE_LIB" >&2
  exit 2
fi

# shellcheck source=.ai-suite/layer2-cognitive/memory/core.sh disable=SC1091
source "$CORE_LIB"

export AI_SUITE_LOG_PREFIX="evolve"

EXCLUDE_MEMORY=0

# -- Argument parsing ----------------------------------------------------------
usage() {
  cat <<'EOF'
ai-suite evolve - sync ai-suite evolutions between remote hosts and local git

USAGE
  ai-suite evolve collect [--local] [--host USER@HOST ...] [--remote-path PATH] [--dry-run]
  ai-suite evolve push    --host USER@HOST [--host ...] [--remote-path PATH]
                          [--remote-scope global|project] [--agent AGENT]
                          [--dry-run]

SUB-COMMANDS
  collect   Pull .ai-suite/ changes from remote host(s) or local global install into the local repo,
            write an evolution report, validate skills, and print git commands.

  push      Rsync the local (evolved) .ai-suite/ to remote host(s), then
            re-run ai-suite enable --scope <remote-scope> on each host.

OPTIONS
  --local               Collect evolutions from the local global installation (~/.cursor/skills, etc.)
  --host USER@HOST      Remote SSH target. Repeat for multiple hosts.
  --remote-path PATH    Remote install directory.
                        Default: \$HOME/.ai-suite-deploy  (resolved on remote)
  --remote-scope SCOPE  Scope for ai-suite enable on remote. Default: global
  --agent AGENT         cursor (default) | claude | opencode | continue | roo-code | all
  --dry-run             Print what would happen; make no changes.
  --help                Show this help.

EXAMPLES
  # After reflection ran on remote host
  ai-suite evolve collect --host alice@dev.example.com

  # Push evolved suite to multiple remotes
  ai-suite evolve push --host alice@dev.example.com --host bob@ci.example.com
EOF
}

# -- Argument parsing ----------------------------------------------------------
SUBCMD=""
HOSTS=()
COLLECT_LOCAL=0
# shellcheck disable=SC2016  # intentional: literal $HOME resolved on remote
REMOTE_PATH='$HOME/.ai-suite-deploy'
REMOTE_SCOPE="global"
AGENT="cursor"
export AI_SUITE_DRY_RUN=0

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

case "$1" in
  collect|push) SUBCMD="$1"; shift ;;
  --help|-h)    usage; exit 0 ;;
  *)            die "Unknown sub-command: '$1'. Use 'collect' or 'push'." 1 ;;
esac

while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)        COLLECT_LOCAL=1; shift ;;
    --host)
      [[ $# -ge 2 ]] || die "--host requires a value" 1
      HOSTS+=("$2"); shift 2 ;;
    --remote-path)
      [[ $# -ge 2 ]] || die "--remote-path requires a value" 1
      REMOTE_PATH="$2"; shift 2 ;;
    --remote-scope)
      [[ $# -ge 2 ]] || die "--remote-scope requires a value" 1
      REMOTE_SCOPE="$2"; shift 2 ;;
    --agent)
      [[ $# -ge 2 ]] || die "--agent requires a value" 1
      AGENT="$2"; shift 2 ;;
    --exclude-memory) EXCLUDE_MEMORY=1; shift ;;
    --dry-run) export AI_SUITE_DRY_RUN=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown option: '$1'" 1 ;;
  esac
done

if [[ ${#HOSTS[@]} -eq 0 && "$COLLECT_LOCAL" == "0" ]]; then
  printf '[evolve] ERROR: --host or --local is required\n' >&2
  printf 'Run: ai-suite evolve --help\n' >&2
  exit 1
fi

# -- Timestamp -----------------------------------------------------------------
TIMESTAMP=$(date -u '+%Y%m%d-%H%M%S')

# -- Helper: sanitize a host string for use in a filename ----------------------
sanitize_host() {
  printf '%s' "$1" | tr -cs 'A-Za-z0-9._-' '_'
}

# -- Sub-command: collect ------------------------------------------------------
do_collect() {
  local any_changed=false
  local all_staged_files=()
  local all_hosts_str="${HOSTS[*]:-}"

  if [[ "$AI_SUITE_DRY_RUN" == "1" ]]; then
    info "[DRY-RUN] collect from: $all_hosts_str"
  fi


    if [[ "$COLLECT_LOCAL" == "1" ]]; then
    info "--- collecting from local global installations ---"
    printf '\n%s=======================================================%s\n' "$(_grn)" "$(_off)"
    printf '%sPlease prompt your AI agent to perform semantic LLM processing:%s\n' "$(_grn)" "$(_off)"
    printf '  > "Please semantically merge the updated capabilities (skills, rules, templates, scripts) from ~/.cursor/skills/, ~/.cursor/rules/, ~/.cursor/templates/, and ~/.cursor/scripts/ into the local .ai-suite/ directory (checking both layer3-registry/core/ and layer1-abstraction/agents/cursor/skills/)."\n'
    printf '%s=======================================================%s\n\n' "$(_grn)" "$(_off)"
  fi

  for HOST in "${HOSTS[@]:-}"; do
    [[ -z "$HOST" ]] && continue
    info "--- collecting from $HOST ---"
    local sanitized
    sanitized=$(sanitize_host "$HOST")

    # Temp dir to receive remote files
    local tmpdir
    tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/evolve-collect.XXXXXX")
    # shellcheck disable=SC2064
    trap "rm -rf '$tmpdir'" EXIT

    local remote_suite="${REMOTE_PATH}/.ai-suite"

    if [[ "$AI_SUITE_DRY_RUN" == "1" ]]; then
      info "[DRY-RUN] Would rsync $HOST:$remote_suite/ -> $tmpdir/"
      info "[DRY-RUN] Would diff $tmpdir/ vs $SUITE_DIR/"
      rm -rf "$tmpdir"
      trap - EXIT
      continue
    fi

    # Fetch remote .ai-suite/ contents
    info "Fetching remote .ai-suite/ from $HOST ..."
    local rsync_opts=(-az --delete)
    if [[ "$EXCLUDE_MEMORY" == "1" ]]; then
      rsync_opts+=(--exclude=memory/)
    fi

    if ! rsync "${rsync_opts[@]}" \
      -e "ssh -o BatchMode=yes -o ConnectTimeout=10" \
      "${HOST}:${remote_suite}/" "${tmpdir}/"; then
      warn "rsync failed for $HOST - skipping"
      rm -rf "$tmpdir"; trap - EXIT
      continue
    fi

    # Compute changed files (relative paths within .ai-suite/)
    local changed_files=()
    local diff_output=""

    while IFS= read -r -d '' f; do
      local rel="${f#"$tmpdir"/}"
      local local_file="$SUITE_DIR/$rel"
      if [[ ! -f "$local_file" ]]; then
        # New file from remote
        changed_files+=("$rel (new)")
        diff_output+="=== NEW: $rel ===\n"
        diff_output+="$(cat "$f")\n\n"
      else
        local file_diff
        file_diff=$(diff -u "$local_file" "$f" || true)
        if [[ -n "$file_diff" ]]; then
          changed_files+=("$rel")
          diff_output+="=== CHANGED: $rel ===\n${file_diff}\n\n"
        fi
      fi
    done < <(find "$tmpdir" -type f -print0 | sort -z)

    if [[ ${#changed_files[@]} -eq 0 ]]; then
      info "No changes detected from $HOST"
      rm -rf "$tmpdir"; trap - EXIT
      continue
    fi

    any_changed=true
    info "Changed files from $HOST:"
    for cf in "${changed_files[@]}"; do
      info "  - $cf"
    done

    # Process changed/new files (Semantic LLM Merging)
    local requires_ai_merge=false
    while IFS= read -r -d '' f; do
      local rel="${f#"$tmpdir"/}"
      local dest="$SUITE_DIR/$rel"
      local dest_dir
      dest_dir="$(dirname "$dest")"
      mkdir -p "$dest_dir"
      
      if [[ -f "$dest" ]]; then
        # File exists locally. Agent will perform semantic merging.
        info "Requires AI semantic merge: $rel"
        requires_ai_merge=true
      else
        # New file
        cp "$f" "$dest"
      fi
      
      all_staged_files+=(".ai-suite/$rel")
    done < <(find "$tmpdir" -type f -print0 | sort -z)

    if $requires_ai_merge; then
      printf '\n%s==============================================================%s\n' \
        "$(_grn)" "$(_off)"
      printf '%s Please prompt your AI agent to perform semantic LLM processing:%s\n' \
        "$(_grn)" "$(_off)"
      printf '  > "Please semantically merge the updated files from %s into the local .ai-suite/ directory."\n' "$tmpdir"
      printf '%s==============================================================%s\n\n' \
        "$(_grn)" "$(_off)"
      # Do not clean up tmpdir so the agent can read it
      trap - EXIT
    else
      rm -rf "$tmpdir"; trap - EXIT
    fi

    # Write evolution report
    local evolutions_dir="$SUITE_DIR/layer4-evolutionary/reflection/evolutions"
    mkdir -p "$evolutions_dir"
    local report_file="$evolutions_dir/${TIMESTAMP}-${sanitized}.md"

    cat > "$report_file" <<REPORT
# Evolution Report: $HOST

**Host:** $HOST
**Timestamp (UTC):** $TIMESTAMP
**Local suite:** $SUITE_DIR

## Changed Files

$(for cf in "${changed_files[@]}"; do echo "- $cf"; done)

## Diffs

$(printf '%s\n' "$diff_output")
REPORT

    info "Evolution report written: $report_file"
    all_staged_files+=(".ai-suite/layer4-evolutionary/reflection/evolutions/${TIMESTAMP}-${sanitized}.md")

    rm -rf "$tmpdir"; trap - EXIT
  done # for HOST

  if [[ "$AI_SUITE_DRY_RUN" == "1" ]]; then
    info "[DRY-RUN] complete - no files were modified."
    return 0
  fi

  if ! $any_changed; then
    info "No changes detected from any host."
    return 0
  fi

  # Run validate-suite.sh (warnings only, do not fail)
  local validator="$SUITE_DIR/layer4-evolutionary/validation/validate-suite.sh"
  if [[ -x "$validator" ]]; then
    info "Running skill validator ..."
    if ! bash "$validator" 2>&1; then
      warn "Skill validation reported issues - review before committing."
    fi
  fi

  # Run ai-suite enable to update the Augmented Agent
  local enabler="$SUITE_ROOT/ai-suite"
  if [[ -x "$enabler" ]]; then
    info "Updating the local Augmented Agent with collected evolution ..."
    bash "$enabler" enable --scope project >/dev/null 2>&1 || warn "Failed to update the Augmented Agent."
  fi

  # Deduplicate staged files list (Bash 3.2 compat: no associative arrays)
  local unique_staged=()
  local _seen_list=" "
  for f in "${all_staged_files[@]}"; do
    case "$_seen_list" in
      *" $f "*) ;;  # already in list
      *) unique_staged+=("$f"); _seen_list="$_seen_list$f " ;;
    esac
  done

  # Emit copy-paste git commands
  local commit_hosts="${HOSTS[*]}"
  printf '\n'
  printf '%s==============================================================%s\n' \
    "$(_grn)" "$(_off)"
  printf '%s Copy-paste git commands to record this evolution:%s\n' \
    "$(_grn)" "$(_off)"
  printf '%s==============================================================%s\n' \
    "$(_grn)" "$(_off)"
  printf '\n'
  printf '  cd %s\n' "$SUITE_ROOT"
  for f in "${unique_staged[@]}"; do
    printf '  git add %s\n' "$f"
  done
  printf '  git commit -m "feat(evolution): collect remote changes from %s at %s"\n' \
    "$commit_hosts" "$TIMESTAMP"
  printf '\n'
  printf '%s==============================================================%s\n\n' \
    "$(_grn)" "$(_off)"
  info "Review the changes above, then run the git commands to commit the evolution."
}

# -- Sub-command: push ---------------------------------------------------------
do_push() {
  local failed_hosts=()
  local total=${#HOSTS[@]}

  if [[ "$AI_SUITE_DRY_RUN" == "1" ]]; then
    info "[DRY-RUN] push to: ${HOSTS[*]}"
  fi


  if [[ "$COLLECT_LOCAL" == "1" ]]; then
    info "--- collecting from local global installations ---"
    local tmpdir
    tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/evolve-collect-local.XXXXXX")
    
    # Simulate a remote .ai-suite structure in tmpdir by copying from local global installations
    mkdir -p "$tmpdir/layer1-abstraction/agents/cursor/skills"
    mkdir -p "$tmpdir/layer1-abstraction/agents/claude/skills"
    
    if [[ -d "$HOME/.cursor/skills" ]]; then
      cp -r "$HOME/.cursor/skills/"* "$tmpdir/layer1-abstraction/agents/cursor/skills/" 2>/dev/null || true
    fi
    if [[ -d "$HOME/.claude/skills" ]]; then
      cp -r "$HOME/.claude/skills/"* "$tmpdir/layer1-abstraction/agents/claude/skills/" 2>/dev/null || true
    fi
    # Also copy core skills if they exist globally (usually they are mirrored to the agent skills)
    
    local changed_files=()
    local diff_output=""
    
    while IFS= read -r -d '' f; do
      local rel="${f#"$tmpdir"/}"
      local src="$SUITE_DIR/$rel"
      if [[ -f "$src" ]]; then
        if ! cmp -s "$src" "$f"; then
          changed_files+=("$rel")
          diff_output+=$(diff -u "$src" "$f" || true)
          diff_output+=$'
'
        fi
      else
        changed_files+=("$rel")
        diff_output+=$(diff -u /dev/null "$f" || true)
        diff_output+=$'
'
      fi
    done < <(find "$tmpdir" -type f -print0)
    
    if [[ ${#changed_files[@]} -gt 0 ]]; then
      info "Found ${#changed_files[@]} changed file(s) locally."
      any_changed=true
      
      if [[ "$AI_SUITE_DRY_RUN" != "1" ]]; then
        for rel in "${changed_files[@]}"; do
          mkdir -p "$(dirname "$SUITE_DIR/$rel")"
          cp "$tmpdir/$rel" "$SUITE_DIR/$rel"
          all_staged_files+=(".ai-suite/$rel")
        done
      fi
      
      # Write a mini-report for local
      local report_file="$SUITE_DIR/layer4-evolutionary/reflection/evolutions/evolution_report_local_$(date +%s).md"
      if [[ "$AI_SUITE_DRY_RUN" != "1" ]]; then
        mkdir -p "$(dirname "$report_file")"
        {
          echo "# Evolution Report: local"
          echo "Date: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
          echo ""
          echo "## Changed Files"
          for rel in "${changed_files[@]}"; do echo "- \`$rel\`"; done
          echo ""
          echo "## Diff"
          echo '```diff'
          printf '%s\n' "$diff_output"
          echo '```'
        } > "$report_file"
        all_staged_files+=(".ai-suite/layer4-evolutionary/reflection/evolutions/$(basename "$report_file")")
        info "Wrote report: $report_file"
      fi
    else
      info "No changes found locally."
    fi
    rm -rf "$tmpdir"
  fi

  for HOST in "${HOSTS[@]:-}"; do
    [[ -z "$HOST" ]] && continue
    info "--- pushing to $HOST ---"
    local remote_dir="$REMOTE_PATH"

    local rsync_cmd=(
      rsync -az
    )
    if [[ "$EXCLUDE_MEMORY" == "1" ]]; then
      rsync_cmd+=(--exclude=memory/)
    fi
    rsync_cmd+=(
      -e "ssh -o BatchMode=yes -o ConnectTimeout=10"
      "$SUITE_DIR/"
      "${HOST}:${remote_dir}/.ai-suite/"
    )
    local enable_cmd=(
      ssh -o BatchMode=yes -o ConnectTimeout=15
      "$HOST"
      "bash ${remote_dir}/ai-suite enable --scope ${REMOTE_SCOPE} --agent ${AGENT}"
    )
    local rsync_scripts=(
      rsync -az
      -e "ssh -o BatchMode=yes -o ConnectTimeout=10"
      "$SUITE_ROOT/ai-suite"
      "${HOST}:${remote_dir}/"
    )

    if [[ "$AI_SUITE_DRY_RUN" == "1" ]]; then
      info "[DRY-RUN] Would run: ${rsync_scripts[*]}"
      info "[DRY-RUN] Would run: ${rsync_cmd[*]}"
      info "[DRY-RUN] Would run: ${enable_cmd[*]}"
      continue
    fi

    if [[ "$REMOTE_PATH" == '$HOME/.ai-suite-deploy' ]]; then
      ssh -o BatchMode=yes -o ConnectTimeout=15 "$HOST" 'if [ -d "$HOME/.ai-suite/.ai-suite" ] && [ ! -d "$HOME/.ai-suite/.git" ]; then echo "Cleaning up old deployment directory $HOME/.ai-suite..."; rm -rf "$HOME/.ai-suite"; fi' || true
    fi

    # Rsync toggle scripts first
    if ! "${rsync_scripts[@]}"; then
      warn "rsync scripts to $HOST failed - skipping host"
      failed_hosts+=("$HOST")
      continue
    fi

    # Rsync .ai-suite/
    if ! "${rsync_cmd[@]}"; then
      warn "rsync .ai-suite/ to $HOST failed - skipping host"
      failed_hosts+=("$HOST")
      continue
    fi

    # Re-run ai-suite enable on remote
    if ! "${enable_cmd[@]}"; then
      warn "ai-suite enable on $HOST failed"
      failed_hosts+=("$HOST")
      continue
    fi

    info "Successfully pushed to $HOST"
  done

  if [[ "$AI_SUITE_DRY_RUN" == "1" ]]; then
    info "[DRY-RUN] complete - no hosts were modified."
    return 0
  fi

  local nfail=${#failed_hosts[@]}
  if [[ $nfail -eq 0 ]]; then
    info "Push complete. All $total host(s) updated successfully."
    return 0
  elif [[ $nfail -eq $total ]]; then
    warn "All $total host(s) failed: ${failed_hosts[*]}"
    return 3
  else
    warn "Partial failure: ${failed_hosts[*]} failed; remaining hosts succeeded."
    return 10
  fi
}

# -- Dispatch ------------------------------------------------------------------
case "$SUBCMD" in
  collect) do_collect ;;
  push)    do_push    ;;
  *)       die "Internal error: unhandled sub-command '$SUBCMD'" 1 ;;
esac
