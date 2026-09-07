# Code Formatting & Style Directive Contracts

## 1. Directive Contracts

### Contract 1.1: Code Quality Standards (`code-quality.md`)
The file `.ai-suite/layer3-registry/directives/code-quality.md` MUST define explicit rules for Code Formatting and Style:
- **Language Standards**: Go code must align with `gofmt` standards; C code must adhere to `clang-format` standards.
- **Project Style Harmony**: Follow the existing code style, naming, and indentation conventions of the target codebase.
- **Clean Empty Lines**: Empty lines must be completely clean (no spaces or tabs on blank lines / no trailing whitespace).
- **Scope Discipline**: Formatting MUST only be applied to newly added or modified lines of code. Unchanged code must NEVER be reformatted unless explicitly requested by the user.

### Contract 1.2: Agent General Directives (`agent-directives.md`)
The file `.ai-suite/layer3-registry/directives/agent-directives.md` MUST include:
- A dedicated section for Code Formatting & Style Standards.
- Explicit language requirements (`gofmt` for Go, `clang-format` for C).
- Strict prohibition against leaving trailing whitespace or spaces/tabs on empty lines.
- Strict prohibition against formatting unchanged code lines.
- Negative constraints explicitly forbidding whole-file reformatting without request and forbidding space/tab-only empty lines.

### Contract 1.3: Code Generation Skills Alignment
Core code-generating skills in `.ai-suite/layer3-registry/core/` (including `tdd-team.md`, `autonomous-team.md`, `ai-review-fix.md`, and `prompt-compiler.md`):
- MUST instruct developers/subagents to follow language formatting standards (`gofmt`, `clang-format`).
- MUST enforce no space/tab-only empty lines.
- MUST enforce selective formatting on modified/added lines only.

### Contract 1.4: Multi-Agent Deployment & Sync
When `ai-suite enable` is executed:
- `.cursor/rules/cursor-suite-code-quality.mdc` and `.cursor/rules/cursor-suite-agent-directives.mdc` must contain the updated directives.
- Agent markdown blocks (e.g. `AGENTS.md`, `CLAUDE.md`) must inherit the formatting directives via `generate_markdown_block`.
