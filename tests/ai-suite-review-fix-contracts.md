# AI Suite Comprehensive Review & Fix Architecture Contracts

## 1. Architectural Findings and Fix Specifications

### 1.1 Memory Isolation & Codex Adapter Architecture
- **Issue**: `codex/adapter.sh` previously contained `$HOME/.ai-suite/memory/codex/tasks` directly inside the script, triggering isolation scanner warnings.
- **Contract**: Memory initialization MUST delegate to standard core memory helpers (`ai_memory_init`) or use standardized path references (`~/.ai-suite/memory/` and `.ai-memory/`), preserving full project isolation and global history separation.

### 1.2 Quality, Efficiency & Parallel Execution in Core Skills
- **Issue**: Several skills (`feature-doc.md`, `codebase-deepdoc.md`, `autonomous-team.md`, `automated-code-reviewer.md`, `ai-review-fix.md`, `prompt-compiler.md`) lacked explicit instructions for parallel tool execution (`Maximize parallel tool calls`) and automated linter/quality checks (`ReadLints`).
- **Contract**: All core analytical, development, and review skills must explicitly instruct the agent to maximize parallel tool execution for independent operations and enforce linter/quality verification.

### 1.3 Dynamic To-Do List Management in Autonomous Delivery Skills
- **Issue**: Skills `tdd-team.md` and `autonomous-team.md` required explicit phrasing confirming dynamic updates to the Master To-Do list upon discovering issues and continuing execution on the new list.
- **Contract**: `tdd-team.md` and `autonomous-team.md` must clearly specify: "Dynamic To-Do list management: continuously maintain and update the To-Do list whenever you found any issues or requirements change, and continue running the new To-Do list until all items are 100% completed."

### 1.4 Test Runner & Path Robustness
- **Issue**: Certain test scripts (`test-publish-contracts.sh`, `test-manage-suite.sh`, `test-cleanup-refactor.sh`, `test-memory-system-evolution.sh`, `test-auto-evolution-contracts.sh`) had bash syntax/path bugs where multi-word CLI commands (e.g. `ai-suite publish`) were quoted as filenames.
- **Contract**: All test scripts must invoke CLI commands properly (`./ai-suite publish`, `./ai-suite manage ...`) and verify actual artifacts deterministically.
