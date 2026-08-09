#!/usr/bin/env bash
# preflight.sh - safety gate before running testbed-setup workflows
# Refuses to allow execution against production-looking targets and captures a
# pre-change baseline so the workflow remains rollback-able.
#
# Usage: preflight.sh <target-host> [extra-blocklist-regex...]
# Exit codes:
#   0 - safe to proceed
#   2 - host matches blocklist (refuse)
#   3 - host unreachable
#   4 - bad invocation

set -euo pipefail

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TARGET="${1:-}"
shift || true
# Use ${@:-} form so set -u doesn't trip on bash 3.2 with zero extra args.
EXTRA_BLOCKLIST=()
if [[ $# -gt 0 ]]; then
    EXTRA_BLOCKLIST=("$@")
fi

if [[ -z "$TARGET" ]]; then
    echo -e "${RED}[ERROR]${NC} usage: $0 <target-host> [extra-blocklist-regex...]" >&2
    exit 4
fi

# Default blocklist - extend via $TESTBED_BLOCKLIST or CLI args.
DEFAULT_BLOCKLIST=(
    '(^|[^a-z])prod([^a-z]|$)'
    '(^|[^a-z])production([^a-z]|$)'
    '-pr-'
    '\.prod\.'
    'release'
    'customer'
)

if [[ -n "${TESTBED_BLOCKLIST:-}" ]]; then
    # Newline-separated regex list from env.
    while IFS= read -r pat; do
        [[ -n "$pat" ]] && DEFAULT_BLOCKLIST+=("$pat")
    done <<< "$TESTBED_BLOCKLIST"
fi

if [[ ${#EXTRA_BLOCKLIST[@]} -gt 0 ]]; then
    DEFAULT_BLOCKLIST+=("${EXTRA_BLOCKLIST[@]}")
fi

# 1. Block known-production patterns.
for pat in "${DEFAULT_BLOCKLIST[@]}"; do
    if [[ "$TARGET" =~ $pat ]]; then
        echo -e "${RED}[BLOCK]${NC} target '$TARGET' matches blocklist pattern '$pat'" >&2
        echo -e "${RED}[BLOCK]${NC} refuse to proceed. Override by editing blocklist or unsetting it explicitly." >&2
        exit 2
    fi
done

# 2. Reachability probe - cheap, no state change.
if ! ping -c 1 -W 2 "$TARGET" >/dev/null 2>&1; then
    echo -e "${YELLOW}[WARN]${NC} $TARGET does not respond to ICMP - continuing to TCP probe" >&2
fi

# Try TCP/22 - tolerate firewalled ICMP, refuse if no SSH.
if ! (echo > /dev/tcp/"$TARGET"/22) >/dev/null 2>&1; then
    echo -e "${RED}[ERROR]${NC} cannot reach $TARGET:22 (ssh)" >&2
    exit 3
fi

# 3. Baseline snapshot directory.
TS="$(date -u +%Y%m%dT%H%M%SZ)"
BASELINE_DIR="${TESTBED_STATE_DIR:-./testbed-state}"
mkdir -p "$BASELINE_DIR"

BASELINE_FILE="$BASELINE_DIR/${TARGET//[^A-Za-z0-9_.-]/_}-${TS}.txt"
echo -e "${BLUE}[INFO]${NC} capturing baseline to $BASELINE_FILE"

# Read-only probes only - never mutate the target here.
ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new \
    "$TARGET" 'uname -a; cat /etc/os-release 2>/dev/null || true; \
               systemctl --failed --no-pager 2>/dev/null || true; \
               df -h; ss -tnlp 2>/dev/null | head -50' \
    > "$BASELINE_FILE" 2>&1 || {
        echo -e "${RED}[ERROR]${NC} baseline capture failed - check SSH access" >&2
        rm -f "$BASELINE_FILE"
        exit 3
    }

echo -e "${GREEN}[OK]${NC} preflight passed for $TARGET. Baseline: $BASELINE_FILE"
exit 0
