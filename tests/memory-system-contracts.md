# AI Suite Memory System Contracts

## 1. Memory Storage Location
- Memory files will be stored in `.ai-memory/`.
- To isolate between agents, the structure will be `.ai-memory/<agent_name>/`.
- Inside the agent memory directory, there will be two main types of memory:
  - `index/`: Layered index memory for project review (e.g., `high-level.md`, `mid-level.md`, `low-level.md`).
  - `tasks/`: Time-sorted task memory (e.g., `YYYY-MM-DD_HH-MM-SS_task.md`).

## 2. Memory Operations (CLI / Bash API)
A new script `.ai-suite/layer2-cognitive/memory/memory.sh` will be created to manage memory operations.
- `ai_memory_init <agent_name>`: Initialize the memory directory for the agent.
- `ai_memory_save_index <agent_name> <level> <content>`: Save index memory at a specific level.
- `ai_memory_load_index <agent_name> <level>`: Load index memory for a specific level.
- `ai_memory_save_task <agent_name> <task_id> <content>`: Save task memory with a timestamp.
- `ai_memory_list_tasks <agent_name>`: List all task memories sorted by time.
- `ai_memory_load_task <agent_name> <task_file>`: Load a specific task memory.
- `ai_memory_save_important <agent_name> <content>`: Save important long-term memory.
- `ai_memory_load_important <agent_name>`: Load important long-term memory.
- `ai_memory_save_layer <agent_name> <layer_name> <content>`: Save layered memory.
- `ai_memory_load_layer <agent_name> <layer_name>`: Load layered memory.
- `ai_memory_list_layers <agent_name>`: List all available memory layers.
- `ai_memory_append_timeline <agent_name> <content>`: Append an event to the timeline memory.
- `ai_memory_read_timeline <agent_name>`: Read the entire timeline memory.
- `ai_memory_clean <agent_name>`: Clean all memory files for the agent.
- `ai_memory_mask <agent_name> <status>`: Temporarily mask memory (status: on/off). If masked, memory load functions will return empty or a masked message.

## 3. Evolution Integration
- `ai-suite evolve` will be updated to support an `--exclude-memory` flag.
- When `--exclude-memory` is provided, `rsync` will use `--exclude 'memory/'` to ignore the memory directory during push and collect.
- `ai-suite publish` should also exclude memory by default or have an option.

## 4. Isolation
- By placing memory in `.ai-memory/`, it is isolated from the project codes.
- By using `<agent_name>` subdirectories, it is isolated between agents.
- The `--exclude-memory` flag ensures it can be isolated from the AI suite evolution process.
