#!/usr/bin/env bash
# opencode adapter: stable interface over the shared managed lifecycle.
set -euo pipefail

agent_install_project() { suite_agent_install "opencode" "$1" project "$2"; }
agent_install_global() { suite_agent_install "opencode" "$1" global "$HOME"; }
agent_uninstall_project() { suite_agent_uninstall "opencode" project "$1"; }
agent_uninstall_global() { suite_agent_uninstall "opencode" global "$HOME"; }
