# AI Suite Memory Usage Contracts

## 1. Core Library Modification
- The `generate_markdown_block` function in `.ai-suite/layer2-cognitive/memory/core.sh` will be updated.
- A new section `### Memory System` will be injected into the generated markdown block.

## 2. Memory System Section Content
- The section will inform the agent about the file-based memory system.
- It will dynamically include the agent's name (`$agent_name` parameter of `generate_markdown_block`).
- It will explicitly instruct the agent to review project memory in `.ai-memory/<agent_name>/index/` and global history memory in `~/.ai-suite/memory/<agent_name>/tasks/` at the start of a task.
- It will instruct the agent to update memory using the bash functions in `.ai-suite/layer2-cognitive/memory/memory.sh` or by editing files directly.

## 3. Agent Prompts
- Since `generate_markdown_block` is used to generate the AI Suite Skills section in `CLAUDE.md` and other agents, this modification will automatically propagate to them.
- For Cursor, the functions `_append_cursorrules_block` and `_append_cursorrules_global_block` in `.ai-suite/layer1-abstraction/agents/cursor/adapter.sh` will also be updated to include the Memory System instructions, ensuring it propagates to `.cursorrules`.

## 4. Memory Storage Split and Auto-Initialization
- The memory system will split storage: `index` (project files memory) will be stored in the project directory (`.ai-memory/<agent_name>/index/`), and `tasks` (history memory) will be stored globally (`~/.ai-suite/memory/<agent_name>/tasks/`).
- The `ai_memory_init` function in `.ai-suite/layer2-cognitive/memory/memory.sh` will automatically create both the project memory directory and the global memory directory.
