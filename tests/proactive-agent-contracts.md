# Proactive Agent Contracts

## Objective
Ensure all agent adapters inject the Proactive Resolution Protocol into the global agent configuration files without breaking existing mechanisms like the Reflection Protocol.

## Adapters to Update
- `.ai-suite/layer1-abstraction/agents/cursor/adapter.sh` (modifies `_append_cursorrules_block` and `_append_cursorrules_global_block`)
- `.ai-suite/layer1-abstraction/agents/claude/adapter.sh` (modifies `_claude_block`)
- `.ai-suite/layer1-abstraction/agents/opencode/adapter.sh` (modifies `_opencode_block`)
- `.ai-suite/layer1-abstraction/agents/continue/adapter.sh` (modifies `_continue_block`)
- `.ai-suite/layer1-abstraction/agents/roo-code/adapter.sh` (modifies `_roo_code_block`)

## Contract Test
A test script will source each adapter, mock the environment, call `agent_install_project`, and assert that the generated rules file contains:
- "Proactive Resolution"
- "analyze the environment"
- "devise a strategy"
- "explore alternative approaches"
- "iterative process"
- "must not compromise existing mechanisms"
- "evolution system"
