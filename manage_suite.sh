#!/usr/bin/env bash
# manage_suite.sh — Manage the ai-suite ecosystem, including domain registry.
#
# Usage:
#   manage_suite.sh domain install <git-url> [--domain <name>]
#
# Example:
#   manage_suite.sh domain install https://github.com/org/ai-skills.git --domain vmware

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_DIR="$SCRIPT_DIR/.ai-suite"

# -- Core Library -------------------------------------------------------------
CORE_LIB="$SUITE_DIR/layer2-cognitive/memory/core.sh"
if [[ ! -f "$CORE_LIB" ]]; then
  printf '[manage_suite] ERROR: core.sh not found: %s\n' "$CORE_LIB" >&2
  exit 2
fi

# shellcheck source=.ai-suite/layer2-cognitive/memory/core.sh disable=SC1091
source "$CORE_LIB"

export AI_SUITE_LOG_PREFIX="manage"

usage() {
  cat <<'EOF'
manage_suite.sh — Manage the ai-suite ecosystem

USAGE
  manage_suite.sh domain install <git-url> [--domain <name>]

SUB-COMMANDS
  domain install    Fetch domain skills from a remote git repository using sparse-checkout.
                    By default it fetches all domains from the remote repo.
                    Use --domain <name> to fetch a specific domain.

OPTIONS
  --domain <name>   Specific domain to install (e.g. vmware)
  --help            Show this help
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

if [[ "$CMD" != "domain" ]]; then
  die "Unknown command: $CMD" 1
fi

SUBCMD="${1:-}"
if [[ -z "$SUBCMD" ]]; then
  die "domain requires a sub-command (e.g. install)" 1
fi
shift

if [[ "$SUBCMD" != "install" ]]; then
  die "Unknown domain sub-command: $SUBCMD" 1
fi

GIT_URL="${1:-}"
if [[ -z "$GIT_URL" || "$GIT_URL" == --* ]]; then
  die "domain install requires a git URL" 1
fi
shift

DOMAIN_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain)
      [[ $# -ge 2 ]] || die "--domain requires a value" 1
      DOMAIN_NAME="$2"
      shift 2
      ;;
    *) die "Unknown option: $1" 1 ;;
  esac
done

do_domain_install() {
  local tmpdir
  tmpdir=$(mktemp_portable "domain-install")
  rm -f "$tmpdir"
  
  info "Cloning $GIT_URL (sparse checkout) ..."
  
  run git clone --depth 1 --filter=blob:none --sparse "$GIT_URL" "$tmpdir"
  
  local target_path=".ai-suite/layer3-registry/domains"
  if [[ -n "$DOMAIN_NAME" ]]; then
    target_path=".ai-suite/layer3-registry/domains/$DOMAIN_NAME"
  fi
  
  info "Checking out $target_path ..."
  run git -C "$tmpdir" sparse-checkout set "$target_path"
  
  if [[ ! -d "$tmpdir/$target_path" ]]; then
    rm -rf "$tmpdir"
    die "Target path $target_path not found in the remote repository." 1
  fi
  
  local local_domains_dir="$SUITE_DIR/layer3-registry/domains"
  mkdir -p "$local_domains_dir"
  
  if [[ -n "$DOMAIN_NAME" ]]; then
    info "Installing domain '$DOMAIN_NAME' ..."
    run cp -r "$tmpdir/$target_path" "$local_domains_dir/"
  else
    info "Installing all domains from repo ..."
    run cp -r "$tmpdir/.ai-suite/layer3-registry/domains/"* "$local_domains_dir/"
  fi
  
  rm -rf "$tmpdir"
  
  # Validate installed domains
  local validator="$SUITE_DIR/layer4-evolutionary/validation/validate-suite.sh"
  if [[ -x "$validator" ]]; then
    info "Running validator ..."
    run "$validator"
  fi
  
  info "Domain install complete."
}

do_domain_install
