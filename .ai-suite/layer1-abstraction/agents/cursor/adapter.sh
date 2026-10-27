#!/usr/bin/env bash
# cursor adapter: stable interface over the shared managed lifecycle.
set -euo pipefail

agent_install_project() { suite_agent_install "cursor" "$1" project "$2"; }
agent_install_global() { suite_agent_install "cursor" "$1" global "$HOME"; }
agent_uninstall_project() { suite_agent_uninstall "cursor" project "$1"; }
agent_uninstall_global() { suite_agent_uninstall "cursor" global "$HOME"; }
