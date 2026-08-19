# Memory Isolation Contracts

## Core Modifications
- `memory.sh` will set `PROJECT_MEMORY_DIR="$SUITE_DIR/../.ai-memory"` (or just `.ai-memory` in the project root). To reliably put it in the project root, we should compute the project root. If `$SUITE_DIR` is `<project>/.ai-suite`, then the project root is `$(dirname "$SUITE_DIR")`. So `PROJECT_MEMORY_DIR="$(dirname "$SUITE_DIR")/.ai-memory"`.
- All `core.sh`, `instructions.md`, `CLAUDE.md`, `.cursorrules`, and adapter prompt templates will instruct agents to look in `.ai-memory/<agent_name>/index/` instead of `.ai-suite/memory/<agent_name>/index/`.

## Exclusion
- `.ai-memory` will be added to `.gitignore`.
- `.ai-memory` is naturally isolated from `ai-suite enable` copying `.ai-suite`. (Wait, `ai-suite enable` copies `.ai-suite/`, so it won't copy `.ai-memory/`).
- `ai-suite evolve` copies `.ai-suite/`, so it won't copy `.ai-memory/`.

## Global Memory
- Global memory remains in `~/.ai-suite/memory/` since it is already outside the source code.
