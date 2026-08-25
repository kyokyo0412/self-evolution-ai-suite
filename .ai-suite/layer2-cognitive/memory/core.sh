#!/usr/bin/env bash
set -euo pipefail
# core.sh — Shared bash library for ai-suite scripts.

if [[ -z "${AI_SUITE_CORE_LOADED:-}" ]]; then
  AI_SUITE_CORE_LOADED=1

  # Load portable helpers if not loaded
  if [[ -z "${CURSOR_SUITE_PORTABLE_LOADED:-}" ]]; then
    # find the script dir that called this
    _CORE_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    _PORTABLE_DIR="$(cd "$_CORE_LIB_DIR/../../layer1-abstraction" && pwd)"
    if [[ -f "$_PORTABLE_DIR/_portable.sh" ]]; then
      # shellcheck source=../../layer1-abstraction/_portable.sh disable=SC1091
      source "$_PORTABLE_DIR/_portable.sh"
    fi
  fi

  # -- Logging -----------------------------------------------------------------
  _grn() { [[ -t 1 ]] && printf '\033[32m' || true; }
  _red() { [[ -t 1 ]] && printf '\033[31m' || true; }
  _yel() { [[ -t 1 ]] && printf '\033[33m' || true; }
  _off() { [[ -t 1 ]] && printf '\033[0m'  || true; }

  # Context prefix allows scripts to set their name (e.g. enable_suite)
  AI_SUITE_LOG_PREFIX="${AI_SUITE_LOG_PREFIX:-ai-suite}"

  log()  { printf '%s[%s]%s %s\n'     "$(_grn)" "$AI_SUITE_LOG_PREFIX" "$(_off)" "$*"; }
  info() { log "$@"; } # alias for log
  warn() { printf '%s[%s] WARN:%s %s\n' "$(_yel)" "$AI_SUITE_LOG_PREFIX" "$(_off)" "$*" >&2; }
  die()  { printf '%s[%s] ERROR:%s %s\n' "$(_red)" "$AI_SUITE_LOG_PREFIX" "$(_off)" "$*" >&2; exit "${2:-1}"; }

  # -- Execution ---------------------------------------------------------------
  # If AI_SUITE_DRY_RUN=1, echo the command instead of running it.
  run() {
    if [[ "${AI_SUITE_DRY_RUN:-0}" == "1" ]]; then
      printf '[dry-run] %q' "$1"
      local arg
      for arg in "${@:2}"; do
        printf ' %q' "$arg"
      done
      printf '\n'
    else
      if [[ "${AI_SUITE_VERBOSE:-0}" == "1" ]]; then
        info "  + $*"
      fi
      "$@"
    fi
  }

  run_redirect_append() {
    local file="$1"; shift
    if [[ "${AI_SUITE_DRY_RUN:-0}" == "1" ]]; then
      printf '[dry-run] (append) >> %q\n' "$file"
    else
      "$@" >> "$file"
    fi
  }

  # -- Skills Discovery --------------------------------------------------------
  get_all_skill_files() {
    local suite_dir="$1"
    local agent_name="${2:-}"
    
    local skill_dirs=( "layer3-registry/core" "layer4-evolutionary/merging" "layer2-cognitive/meta-compiler" )
    if [[ -n "$agent_name" ]]; then
      skill_dirs+=( "layer1-abstraction/agents/$agent_name/skills" )
    fi
    
    if [[ -d "$suite_dir/layer3-registry/domains" ]]; then
      if [[ -n "${AI_SUITE_DOMAIN:-}" ]]; then
        if [[ -d "$suite_dir/layer3-registry/domains/$AI_SUITE_DOMAIN/skills" ]]; then
          skill_dirs+=( "layer3-registry/domains/$AI_SUITE_DOMAIN/skills" )
        fi
      else
        for domain in "$suite_dir"/layer3-registry/domains/*; do
          [[ -d "$domain" ]] || continue
          skill_dirs+=( "layer3-registry/domains/$(basename "$domain")/skills" )
        done
      fi
    fi
    
    for skill_dir in "${skill_dirs[@]}"; do
      local dir="$suite_dir/$skill_dir"
      [[ -d "$dir" ]] || continue
      for f in "$dir"/*.md; do
        [[ -f "$f" ]] || continue
        echo "$f"
      done
    done
  }

  _mirror_rules() {
    local suite_dir="$1"
    local rules_dest="$2"
    local agent_name="${3:-}"
    local count=0

    local rule_dirs=( "layer3-registry/rules" "layer4-evolutionary/rules" "layer2-cognitive/rules" )
    if [[ -n "$agent_name" ]]; then
      rule_dirs+=( "layer1-abstraction/agents/$agent_name/rules" )
    fi

    if [[ -d "$suite_dir/layer3-registry/domains" ]]; then
      if [[ -n "${AI_SUITE_DOMAIN:-}" ]]; then
        if [[ -d "$suite_dir/layer3-registry/domains/$AI_SUITE_DOMAIN/rules" ]]; then
          rule_dirs+=( "layer3-registry/domains/$AI_SUITE_DOMAIN/rules" )
        fi
      else
        for domain in "$suite_dir"/layer3-registry/domains/*; do
          [[ -d "$domain" ]] || continue
          rule_dirs+=( "layer3-registry/domains/$(basename "$domain")/rules" )
        done
      fi
    fi

    mkdir -p "$rules_dest"
    for r_dir in "${rule_dirs[@]}"; do
      local dir="$suite_dir/$r_dir"
      [[ -d "$dir" ]] || continue
      for f in "$dir"/*; do
        [[ -f "$f" ]] || continue
        cp "$f" "$rules_dest/"
        count=$((count+1))
      done
    done

    printf '[ai-suite] mirrored %d rule(s) to %s\n' "$count" "$rules_dest"
  }

  _mirror_templates() {
    local suite_dir="$1"
    local dest="$2"
    local agent_name="${3:-}"
    local count=0

    local t_dirs=( "layer3-registry/templates" "layer2-cognitive/templates" )
    if [[ -n "$agent_name" ]]; then
      t_dirs+=( "layer1-abstraction/agents/$agent_name/templates" )
    fi

    if [[ -d "$suite_dir/layer3-registry/domains" ]]; then
      if [[ -n "${AI_SUITE_DOMAIN:-}" ]]; then
        if [[ -d "$suite_dir/layer3-registry/domains/$AI_SUITE_DOMAIN/templates" ]]; then
          t_dirs+=( "layer3-registry/domains/$AI_SUITE_DOMAIN/templates" )
        fi
      else
        for domain in "$suite_dir"/layer3-registry/domains/*; do
          [[ -d "$domain" ]] || continue
          t_dirs+=( "layer3-registry/domains/$(basename "$domain")/templates" )
        done
      fi
    fi

    mkdir -p "$dest"
    for t_dir in "${t_dirs[@]}"; do
      local dir="$suite_dir/$t_dir"
      [[ -d "$dir" ]] || continue
      cp -r "$dir"/* "$dest/" 2>/dev/null || true
      count=$((count+1))
    done

    printf '[ai-suite] mirrored templates to %s\n' "$dest"
  }

  _mirror_scripts() {
    local suite_dir="$1"
    local dest="$2"
    local agent_name="${3:-}"
    local count=0

    local s_dirs=( "layer3-registry/scripts" "layer2-cognitive/scripts" "layer4-evolutionary/scripts" )
    if [[ -n "$agent_name" ]]; then
      s_dirs+=( "layer1-abstraction/agents/$agent_name/scripts" )
    fi

    if [[ -d "$suite_dir/layer3-registry/domains" ]]; then
      if [[ -n "${AI_SUITE_DOMAIN:-}" ]]; then
        if [[ -d "$suite_dir/layer3-registry/domains/$AI_SUITE_DOMAIN/scripts" ]]; then
          s_dirs+=( "layer3-registry/domains/$AI_SUITE_DOMAIN/scripts" )
        fi
      else
        for domain in "$suite_dir"/layer3-registry/domains/*; do
          [[ -d "$domain" ]] || continue
          s_dirs+=( "layer3-registry/domains/$(basename "$domain")/scripts" )
        done
      fi
    fi

    mkdir -p "$dest"
    for s_dir in "${s_dirs[@]}"; do
      local dir="$suite_dir/$s_dir"
      [[ -d "$dir" ]] || continue
      cp -r "$dir"/* "$dest/" 2>/dev/null || true
      count=$((count+1))
    done

    printf '[ai-suite] mirrored scripts to %s\n' "$dest"
  }

  _mirror_skills() {
    local suite_dir="$1"
    local skills_dest="$2"
    local agent_name="${3:-}"
    local count=0

    while IFS= read -r f; do
      [[ -f "$f" ]] || continue
      local name; name=$(basename "$f" .md)
      mkdir -p "$skills_dest/$name"
      cp "$f" "$skills_dest/$name/SKILL.md"
      local skill_dir_path; skill_dir_path=$(dirname "$f")
      if [[ -d "$skill_dir_path/scripts/$name" ]]; then
        mkdir -p "$skills_dest/$name/scripts"
        cp -r "$skill_dir_path/scripts/$name"/* "$skills_dest/$name/scripts/" 2>/dev/null || true
      fi
      if [[ -d "$skill_dir_path/templates/$name" ]]; then
        mkdir -p "$skills_dest/$name/templates"
        cp -r "$skill_dir_path/templates/$name"/* "$skills_dest/$name/templates/" 2>/dev/null || true
      fi
      if [[ -d "$skill_dir_path/rules/$name" ]]; then
        mkdir -p "$skills_dest/$name/rules"
        cp -r "$skill_dir_path/rules/$name"/* "$skills_dest/$name/rules/" 2>/dev/null || true
      fi
      count=$((count+1))
    done < <(get_all_skill_files "$suite_dir" "$agent_name")

    printf '[ai-suite] mirrored %d skill(s) to %s\n' "$count" "$skills_dest"
  }

  
  _remove_rules() {
    local rules_dest="$1"
    local suite_dir="$2"
    # We don't remove the whole directory because user might have their own rules
    # But we can remove the ones we mirrored.
    if [[ -d "$rules_dest" && -d "$suite_dir" ]]; then
      # Find all rules that might have been copied from anywhere in the suite and remove them
      find "$suite_dir" -name "*.mdc" -type f -exec basename {} \; 2>/dev/null | while read rule_file; do
        rm -f "$rules_dest/$rule_file"
      done
      # specific removals
      rm -f "$rules_dest"/interactive-workflow.md 2>/dev/null || true
    fi
  }

  _remove_skills() {
    local skills_dest="$1"
    if [[ -d "$skills_dest" ]]; then
      rm -rf "$skills_dest"
    fi
  }

  _mirror_meta() {
    local suite_dir="$1"
    local meta_dest="$2"
    mkdir -p "$meta_dest"
    cp -r "$suite_dir/layer4-evolutionary/validation/"* "$meta_dest/" 2>/dev/null || true
    cp -r "$suite_dir/layer4-evolutionary/reflection/"* "$meta_dest/" 2>/dev/null || true
    
    # Copy root scripts to meta_dest/scripts so the AI suite Agent can use them
    local root_dir="$(cd "$suite_dir/.." && pwd)"
    mkdir -p "$meta_dest/scripts"
    cp "$root_dir"/*.sh "$meta_dest/scripts/" 2>/dev/null || true
    cp "$suite_dir/layer2-cognitive/memory/core.sh" "$meta_dest/scripts/" 2>/dev/null || true
  }

  _remove_meta() {
    local meta_dest="$1"
    if [[ -d "$meta_dest" ]]; then
      rm -rf "$meta_dest"
    fi
  }

  AI_SUITE_PROACTIVE_RESOLUTION="When you encounter an issue or are given a problem, you must proactively resolve it. Analyze the environment and the problem, devise a strategy, and attempt to implement it. If an initial attempt fails, explore alternative approaches from various angles. Engage in an iterative process of analysis, action, and experimentation until the problem is resolved, and report the details. These enhancements must not compromise existing mechanisms, such as the evolution system.
Never-Give-Up Spirit: When explicitly instructed not to give up on a task, you must persist—exhausting all possible solutions and making repeated attempts—to complete the assigned task. The single most critical constraint during this persistent execution is the absolute prohibition against damaging the production environment. Otherwise, it should run as normal mode."

  # -- File Block Management ---------------------------------------------------
  remove_block_from_file() {
    local file="$1"
    local start_marker="$2"
    local end_marker="$3"
    [[ -f "$file" ]] || return 0
    local tmpfile
    tmpfile=$(mktemp "${TMPDIR:-/tmp}/ai-suite-block.XXXXXX")
    local in_block=false
    while IFS= read -r line; do
      if [[ "$line" == "$start_marker" ]]; then
        in_block=true
        continue
      fi
      if [[ "$line" == "$end_marker" ]]; then
        in_block=false
        continue
      fi
      $in_block || printf '%s\n' "$line" >> "$tmpfile"
    done < "$file"
    mv "$tmpfile" "$file"
  }

  generate_markdown_block() {
    local suite_dir="$1"
    local target_dir="$2"
    local agent_name="$3"
    local start_marker="$4"
    local end_marker="$5"
    local meta_dir="$target_dir/meta"
    local skills_dir="$target_dir/skills"

    if [[ -n "$start_marker" ]]; then
      printf '%s\n' "$start_marker"
    fi
    
    cat <<HEADER
## AI Suite Skills

This project uses the **ai-suite** framework. The following skills are available.
Activate one by including its trigger phrase in your request, or follow the skill
instructions directly.

### Skill Index
HEADER

    while IFS= read -r skill_file; do
      [[ -f "$skill_file" ]] || continue
      local sname sdesc
      sname=$(grep '^name:' "$skill_file" | head -1 | sed 's/name: *//')
      sdesc=$(grep '^description:' "$skill_file" | head -1 \
              | sed 's/description: *//' \
              | sed 's/Use when.*//' \
              | tr -d '"' \
              | sed 's/[[:space:]]*$//')
      printf -- '- **%s** — %s\n' "$sname" "$sdesc"
    done < <(get_all_skill_files "$suite_dir" "$agent_name")

    cat <<FOOTER

### AI-Expert Prompt Optimization
Before executing complex tasks, automatically apply the **ai-expert** skill to analyze and optimize the user's request.

### Reflection Protocol
After any task, type **"Run Reflection"** to analyse what went wrong or could be
faster and improve the relevant skill automatically. Never auto-commit.
See $meta_dir/reflection-protocol.md for details.

### Proactive Resolution
$AI_SUITE_PROACTIVE_RESOLUTION

### Auto-Evolution Directive
If a task required more than 1 attempt, or involved complex design changes, you MUST automatically execute the Reflection Protocol (\$meta_dir/reflection-protocol.md) at the end of the task, without waiting for the user to ask.

### Memory System
The AI suite has a file-based memory system to store project indexes and task history.
Your agent name is \`$agent_name\`.
When starting a task, review the project memory in \`.ai-memory/$agent_name/index/\` and global history memory in \`~/.ai-suite/memory/$agent_name/tasks/\`.
If you learn new facts or complete a task, update the memory using the bash functions in \`.ai-suite/layer2-cognitive/memory/memory.sh\` or by directly editing the files.

- **To discover available memory**, run \`ai_memory_summary $agent_name\`
- **To search memory**, run \`ai_memory_search $agent_name "keyword"\`


### Usage
Refer to $skills_dir/<skill-name>/SKILL.md for full instructions.
FOOTER

    for src in "$suite_dir/layer3-registry/directives/"*.md; do
      [[ -f "$src" ]] || continue
      cat "$src"
      echo ""
    done
    for src in "$suite_dir/layer3-registry/safety/"*.md; do
      [[ -f "$src" ]] || continue
      cat "$src"
      echo ""
    done

    if [[ -n "$end_marker" ]]; then
      printf '%s\n' "$end_marker"
    fi
  }

fi
