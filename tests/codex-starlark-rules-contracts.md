# Architecture & Interface Contracts: Codex Starlark Rules vs AGENTS.md Migration

## 1. Context & Motivation
Codex uses `.codex/rules/` (and `~/.codex/rules/`) as an execution-rule directory intended for Starlark-syntax execution and sandbox configuration policies.
Markdown prompt rules (such as general directives, code quality standards, 1E-class security standards, and domain rules) are natural-language prompt instructions and must be mapped exclusively to Codex's primary instruction file (`AGENTS.md`).
Placing markdown files (`.md` or `.mdc`) in `.codex/rules/` violates Codex's Starlark execution rules expectations.

## 2. Interface Contracts

### 2.1 AGENTS.md Inlined Prompt Contract
- When `agent_install_project` or `agent_install_global` runs for agent `codex`:
  - An managed sentinel block (`<!-- ai-suite:start -->` ... `<!-- ai-suite:end -->`) is generated and appended/updated in `AGENTS.md`.
  - The block includes:
    - AI Suite Skills Index
    - Cognitive Memory hooks and triggers
    - `## AI Suite Directives & Rules` section containing:
      - Directives (`layer3-registry/directives/*.md`)
      - Safety rules (`layer3-registry/safety/*.md`)
      - Core/Cognitive/Evolutionary rules (`layer3-registry/rules`, `layer2-cognitive/rules`, `layer4-evolutionary/rules`)
      - Domain-specific rules (when active)
  - All inlined rules MUST have YAML frontmatter (`---` headers, `alwaysApply:`, `globs:`, etc.) cleanly stripped.

### 2.2 .codex/rules Non-Pollution Contract
- The Codex adapter MUST NOT copy any Markdown prompt rules (`.md` or `.mdc`) into `.codex/rules/`.
- The `.codex/rules` directory is reserved strictly for native Codex Starlark-syntax `.rules` execution files.

### 2.3 Component Population Contract
- `.codex/skills/`: Contains mirrored skill definitions (`SKILL.md`).
- `.codex/templates/`: Contains mirrored templates from `layer2-cognitive/templates/`.
- `.codex/scripts/`: Contains mirrored cognitive scripts (`memory.sh`, `core.sh`, `ai-suite`).
- `.codex/meta/`: Contains reflection protocols and validation scripts.
- `.codex/directives/`: Contains standalone directives for file-based prompt lookup.

### 2.4 Uninstallation & Cleanup Contract
- `agent_uninstall_project` and `agent_uninstall_global` cleanly remove:
  - Mirrored directories (`.codex/skills`, `.codex/meta`, `.codex/templates`, `.codex/scripts`, `.codex/directives`).
  - Managed sentinel block from `AGENTS.md`.
