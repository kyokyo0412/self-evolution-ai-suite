#!/usr/bin/env bash
# ai-suite manage -- Manage the ai-suite ecosystem, including domain registry.
#
# Usage:
#   ai-suite manage domain install <git-url> [--domain <name>]
#
# Example:
#   ai-suite manage domain install https://github.com/org/ai-skills.git --domain custom_domain

set -euo pipefail

ORIGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$ORIGIN_DIR/../layer1-abstraction/runtime/layout.sh"
suite_resolve_layout "$ORIGIN_DIR"

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
ai-suite manage -- Manage the ai-suite ecosystem

USAGE
  ai-suite manage domain install <git-url> [--domain <name>]

SUB-COMMANDS
  domain install    Fetch domain skills from a remote git repository using sparse-checkout.
                    By default it fetches all domains from the remote repo.
                    Use --domain <name> to fetch a specific domain.

OPTIONS
  --domain <name>   Specific domain to install (e.g. custom_domain)
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
  PYTHONDONTWRITEBYTECODE=1 python3 "$SUITE_DIR/layer1-abstraction/runtime/domains.py" \
    "$SUITE_DIR" "$GIT_URL" --domain "$DOMAIN_NAME"
}

do_domain_install
