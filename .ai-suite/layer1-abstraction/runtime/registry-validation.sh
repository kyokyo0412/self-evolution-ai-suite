#!/usr/bin/env bash
# Canonical registry API; sourceable through the compatibility core facade.
_SUITE_REGISTRY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

suite_registry_validate() {
  command -v python3 >/dev/null || { printf 'python3 is required\n' >&2; return 1; }
  PYTHONDONTWRITEBYTECODE=1 python3 "$_SUITE_REGISTRY_DIR/registry.py" validate "$1" --agent "${2:-all}"
}

suite_registry_list() {
  command -v python3 >/dev/null || { printf 'python3 is required\n' >&2; return 1; }
  PYTHONDONTWRITEBYTECODE=1 python3 "$_SUITE_REGISTRY_DIR/registry.py" list "$1" --agent "${2:-}"
}
