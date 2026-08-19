# AI Suite Memory System V2 Contracts

## Bash Functions (in `.ai-suite/layer2-cognitive/memory/memory.sh`)

1. `ai_memory_summary <agent_name>`
   - **Input**: `agent_name`
   - **Behavior**: Lists all memory layers in the project index/layers. Lists all recent tasks in the global memory. Outputs the word count/lines of timeline and important memories if they exist.
   - **Output**: Formatted summary text.

2. `ai_memory_search <agent_name> <keyword>`
   - **Input**: `agent_name` and a `keyword` (regex string).
   - **Behavior**: Uses `grep -inrE` (or similar) to search the `keyword` across all `.md` files in `.ai-memory/<agent_name>` and `~/.ai-suite/memory/<agent_name>`.
   - **Output**: File names and matched lines.

## Prompt Injection (in `.ai-suite/layer2-cognitive/memory/core.sh`)
- In `generate_markdown_block()`, the memory section MUST include text like:
  - "To discover what memory you have, run `ai_memory_summary <agent_name>`."
  - "To search past memory for a specific topic, run `ai_memory_search <agent_name> <keyword>`."
