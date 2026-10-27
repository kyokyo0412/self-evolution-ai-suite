#!/usr/bin/env bash
# claude adapter: stable interface over the shared managed lifecycle.
set -euo pipefail

agent_install_project() { suite_agent_install "claude" "$1" project "$2"; }
agent_install_global() { suite_agent_install "claude" "$1" global "$HOME"; }
agent_uninstall_project() { suite_agent_uninstall "claude" project "$1"; }
agent_uninstall_global() { suite_agent_uninstall "claude" global "$HOME"; }
