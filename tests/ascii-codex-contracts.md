# ASCII Cleanliness and Codex Agent Contracts

## 1. ASCII Cleanliness Contract
- All text files in the repository MUST contain only standard ASCII characters (0x00 - 0x7F).
- Corrupted byte sequences (such as terminal mojibake `\xe2M-^]M-^L` or `\xf0M-^_M-^[M-^Q`) MUST be replaced with standard ASCII text equivalents.
- Non-ASCII punctuation, mathematical symbols, arrows, and emojis MUST be mapped to clean ASCII equivalents:
  - Em-dash / En-dash: `--` or `-`
  - Arrows: `->`, `<-`, `<->`
  - Ellipsis: `...`
  - Multiplication: `x`
  - Comparisons: `<=`, `>=`
  - Emojis: `[X]`, `[OK]`, `[STOP]`, `[WARN]`
  - Quotes: standard single `'` and double `"` quotes
  - Box drawing chars: `|--`, `|`, `\--`, `-`

## 2. Codex Agent Adapter Contract
- **File path**: `.ai-suite/layer1-abstraction/agents/codex/adapter.sh`
- **Project Target File**: `$project_dir/AGENTS.md`
- **Global Target File**: `$HOME/.codex/AGENTS.md`
- **Skills Directory**:
  - Project: `$project_dir/.codex/skills`
  - Global: `$HOME/.codex/skills`
- **Meta Directory**:
  - Project: `$project_dir/.codex/meta`
  - Global: `$HOME/.codex/meta`
- **Sentinels**:
  - Start: `<!-- ai-suite:start -->`
  - End: `<!-- ai-suite:end -->`
- **Directives and Safety Rules**:
  - Codex receives all AI Suite directives and safety rules embedded in `AGENTS.md` via `generate_markdown_block`.
- **Uninstallation**:
  - Strips sentinel block from `AGENTS.md` (and legacy `.codexrules` if present).
  - Removes `.codex/skills` and `.codex/meta`.

## 3. Multi-Agent Interoperability Contract
- Cursor, Claude, OpenCode, Continue, Roo-Code, and Codex agents all follow the standard adapter lifecycle:
  - `agent_install_project <SUITE_DIR> <PROJECT_DIR>`
  - `agent_install_global <SUITE_DIR>`
  - `agent_uninstall_project <PROJECT_DIR>`
  - `agent_uninstall_global`
