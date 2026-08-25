#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

if [[ -d "$SCRIPT_DIR/.ai-suite" ]]; then
  SUITE_DIR="$SCRIPT_DIR/.ai-suite"
elif [[ "$SCRIPT_DIR" == */meta/scripts ]]; then
  # Running from ~/.cursor/meta/scripts
  META_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
  CURSOR_DIR="$(cd "$META_DIR/.." && pwd)"
  SUITE_DIR="$CURSOR_DIR" # This is a pseudo-suite dir
else
  echo "Error: Cannot determine AI suite context from $SCRIPT_DIR" >&2
  exit 2
fi

# -- Core Library -------------------------------------------------------------
if [[ -f "$SUITE_DIR/layer2-cognitive/memory/core.sh" ]]; then
  CORE_LIB="$SUITE_DIR/layer2-cognitive/memory/core.sh"
elif [[ -f "$SCRIPT_DIR/core.sh" ]]; then
  # If core.sh was copied to scripts/
  CORE_LIB="$SCRIPT_DIR/core.sh"
else
  printf '[workflow] ERROR: core.sh not found\n' >&2
  exit 2
fi
# shellcheck source=/dev/null
source "$CORE_LIB"

export AI_SUITE_LOG_PREFIX="workflow"

usage() {
  cat <<'EOF'
ai-suite workflow - Streamlined workflow orchestration for ai-suite

USAGE
  ai-suite workflow <command> [options]

COMMANDS
  evolve      Trigger reflection and collect local evolutions
              Options: --dry-run
              
  absorb      Fetch capabilities from an external agent and merge locally
              Options: --host USER@HOST --remote-path PATH
                       --local
                       --local-path PATH
                       --dry-run
              
  integrate   Push local ai-suite capabilities to an external agent
              Options: --host USER@HOST --remote-path PATH
                       --dry-run

  enable      Enable the AI suite for the agent
              Delegates to ai-suite enable (supports its options)

  disable     Disable the AI suite for the agent
              Delegates to ai-suite disable (supports its options)

  publish     Publish the AI suite as a tar package
              Delegates to ai-suite publish (supports its options)

  develop     Show instructions for developing the AI suite
              Options: --dry-run
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

CMD="${1:-}"
shift

if [[ "$CMD" == "--help" || "$CMD" == "-h" ]]; then
  usage
  exit 0
fi

DRY_RUN=0

has_dry_run() {
  for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
      return 0
    fi
  done
  return 1
}
if has_dry_run "$@"; then
  DRY_RUN=1
fi

do_evolve() {
  if [[ "$DRY_RUN" == 1 ]]; then
    info "[DRY-RUN] Would prompt for reflection and collect evolutions"
    return 0
  fi
  
  info "Workflow: Evolve"
  printf "\n=======================================================\n"
  printf "Please ask your AI agent to run the reflection protocol:\n"
  printf "  > Run the reflection protocol to extract new skills.\n"
  printf "=======================================================\n\n"
  
  info "After reflection completes, run ./ai-suite evolve collect (if from remote)"
  info "or manually git add the files in .ai-suite/layer4-evolutionary/reflection/evolutions/ (if local)."
  
  # Check if there are new untracked/modified evolution files
  local uncommitted
  uncommitted=$(git status --porcelain .ai-suite/layer4-evolutionary/reflection/evolutions/ 2>/dev/null || true)
  if [[ -n "$uncommitted" ]]; then
    info "Found new evolutions locally:"
    echo "$uncommitted"
    printf "Run: \n  git add .ai-suite/layer4-evolutionary/reflection/evolutions/\n  git commit -m 'feat(evolution): collect local evolutions'\n"
  else
    info "No new local evolutions found."
  fi
}

do_absorb() {
  if [[ "$DRY_RUN" == 1 ]]; then
    info "[DRY-RUN] Would instruct AI agent to perform semantic absorption"
    return 0
  fi
  
  info "Workflow: Absorb"
  info "======================================================="
  info "Please prompt your AI agent to perform semantic absorption:"
  info "  > Execute the absorb-capability skill with arguments: ${*:-}"
  info "======================================================="
}

do_integrate() {
  if [[ "$DRY_RUN" == 1 ]]; then
    info "[DRY-RUN] Would instruct AI agent to perform semantic integration"
    return 0
  fi
  
  info "Workflow: Integrate"
  info "======================================================="
  info "Please prompt your AI agent to perform semantic integration:"
  info "  > Execute the integrate-capability skill for target ${*:-}"
  info "======================================================="
}

do_enable() {
  info "Workflow: Enable"
  exec "$SCRIPT_DIR/enable.sh" "$@"
}

do_disable() {
  info "Workflow: Disable"
  exec "$SCRIPT_DIR/disable.sh" "$@"
}

do_publish() {
  info "Workflow: Publish"
  exec "$SCRIPT_DIR/publish.sh" "$@"
}

do_develop() {
  if [[ "$DRY_RUN" == 1 ]]; then
    info "[DRY-RUN] Would print AI Suite Development instructions"
    return 0
  fi
  info "Workflow: AI Suite Development"
  printf "\n=======================================================\n"
  printf "AI Suite Development Environment Setup:\n"
  printf "1. The developing AI suite code must be isolated from the\n"
  printf "   running AI suite Agent config (configuration, skills, etc).\n"
  printf "2. Enable the AI suite on your agent using --scope global.\n"
  printf "   Do NOT use --scope project inside the AI suite source repo.\n"
  printf "   (If you accidentally did, run scripts/clean_dev_env.sh)\n"
  printf "3. To collect local evolutions from your global installation\n"
  printf "   back into the source repo, run:\n"
  printf "     ./ai-suite evolve collect --local\n"
  printf "4. User will ONLY manually commit the developing AI suite code\n"
  printf "   to the git repository. The agent will never auto commit.\n"
  printf "=======================================================\n\n"
}

case "$CMD" in
  evolve)    do_evolve "$@" ;;
  absorb)    do_absorb "$@" ;;
  integrate) do_integrate "$@" ;;
  enable)    do_enable "$@" ;;
  disable)   do_disable "$@" ;;
  publish)   do_publish "$@" ;;
  develop)   do_develop "$@" ;;
  *)         die "Unknown command: $CMD" 1 ;;
esac
