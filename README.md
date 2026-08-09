# Self-Evolving AI Suite

A **multi-agent, self-evolving AI framework** that enables coding agents to learn from every task, share improvements across projects, and distribute evolved capabilities to remote machines. Built entirely in portable Bash for macOS and Linux.

## What It Does

| Capability | Description |
|---|---|
| **Multi-Agent Support** | Installs into Cursor, Claude Code, OpenCode, Continue, and Roo Code with a single command |
| **Self-Reflection** | After any task, agents analyze their performance across six categories (trigger accuracy, instruction completeness, safety, efficiency, output quality, tier placement) and improve their own skills |
| **Cross-Host Evolution** | Collect evolved skills from remote SSH machines back into the local git repository, or push local improvements to multiple hosts |
| **Production Safety** | Hard-coded safety guards refuse destructive commands (`rm -rf`, `git push --force`, raw disk writes) and require explicit confirmation for state-changing operations |
| **Domain Registry** | Install skill domains from external git repositories (e.g., Microsoft-specific or VMware-specific AI skills) |
| **Memory System** | File-based project indexing and task history for persistent agent memory |

## Architecture

```
.ai-suite/
├── layer1-abstraction/     Agent adapters — translates suite rules to each agent's config format
│   └── agents/
│       ├── cursor/         → .cursorrules, .cursor/rules/*.mdc, ~/.cursor/skills/
│       ├── claude/         → CLAUDE.md, .claude/skills/, ~/.claude/
│       ├── opencode/       → .opencode/instructions.md
│       ├── continue/       → .continue/prompts/ai-suite.prompt
│       └── roo-code/       → .roorules
├── layer2-cognitive/       Memory system, prompt templates, meta-compiler
│   ├── memory/             File-based project index & task history
│   └── templates/          Prompt briefs & documentation templates
├── layer3-registry/        Directive registry & safety policies
│   ├── core/               Agent-agnostic skills (TDD, code review, deep doc, etc.)
│   ├── directives/         Agent behavior directives (step visibility, agent rules)
│   └── safety/             Production safety guardrails
└── layer4-evolutionary/    Self-improvement & distribution
    ├── reflection/         Reflection protocol & evolution reports
    ├── merging/            Skill absorption, integration, & publishing
    ├── validation/         Suite validator, acceptance tests, preflight checks
    └── validation/scripts/ Test scripts for workflow features
```

## Quick Start

### Install for a Project

```bash
# Install for Cursor (default) in the current workspace
bash enable_suite.sh --scope project --agent cursor

# Install for all supported agents
bash enable_suite.sh --scope project --agent all
```

### Install Globally

```bash
# Makes the suite available across all your projects
bash enable_suite.sh --scope global --agent cursor
```

### Deploy to a Remote Host

```bash
bash enable_suite.sh --scope remote --host user@host --agent all
```

### Uninstall

```bash
bash disable_suite.sh --scope project --agent cursor
bash disable_suite.sh --scope global --agent all
```

### Enable Auto-Activation

Add a shell hook so the suite auto-enables when you `cd` into a project:

```bash
bash enable_suite.sh --install-hook --shell both
```

## Evolution Workflow

The core innovation of the ai-suite is its **self-evolution loop**:

```
Task Complete → Run Reflection → Generate Evolution Report → Collect → Push
```

1. **Reflect** — After completing a task, the agent triggers the Reflection Protocol to analyze performance, identify issues, and edit skill files for improvement
2. **Collect** — Pull evolved skills from remote machines or your local global installation back into the git repo:
   ```bash
   ./evolve_suite.sh collect --host user@host
   ./evolve_suite.sh collect --local
   ```
3. **Push** — Distribute your local improvements to one or more remote hosts:
   ```bash
   ./evolve_suite.sh push --host user@host1 --host user@host2
   ```
4. **Publish** — Package the suite for distribution:
   ```bash
   bash publish_suite.sh
   # → ai-suite-package.tar.gz
   ```

## Commands Reference

| Script | Purpose |
|---|---|
| `enable_suite.sh` | Install/activate the suite (project, global, or remote scope) |
| `disable_suite.sh` | Cleanly remove the suite from a scope |
| `evolve_suite.sh` | Collect or push evolutions between local repo and remote hosts |
| `manage_suite.sh` | Install skill domains from external git repositories |
| `publish_suite.sh` | Create a distributable tarball (excludes vendor-specific domains) |
| `ai_suite_workflow.sh` | Orchestrate the full workflow (enable → evolve → publish) |

### Common Flags

| Flag | Usage |
|---|---|
| `--scope project` | Install into current workspace |
| `--scope global` | Install user-globally |
| `--scope remote` | Deploy to SSH host (requires `--host`) |
| `--agent <name>` | `cursor`, `claude`, `opencode`, `continue`, `roo-code`, or `all` |
| `--dry-run` | Preview changes without writing files |
| `--verify` | Lint all skill directories and exit |
| `--install-hook` | Add auto-enable hook to shell rc files |

## Core Skills

The suite ships with agent-agnostic skills in `layer3-registry/core/`:

- **tdd-team** — Stage-gated TDD/BDD development cycle (PM, Architect, SDET, Developer, Tech Writer)
- **autonomous-team** — End-to-end feature delivery without strict TDD stage gates
- **ai-review-fix** — Resolve code review comments from URLs (Gerrit, GitHub PRs)
- **automated-code-reviewer** — Security-focused code review and best-practice audit
- **codebase-deepdoc** — Full architectural documentation generation with Mermaid diagrams
- **bazel-deb-deps** — Translate Bazel BUILD files to Debian/Ubuntu apt dependency trees
- **testbed-setup** — Remote ESX/Linux VM provisioning over SSH
- **find-skill** — AI workflow discovery system
- And more…

## Safety

Production safety is the highest priority. The suite's guardrails:

- **Refuse destructive commands** — `rm -rf /`, `chmod -R 777`, fork bombs, raw disk writes
- **Block unauthorized git operations** — No autonomous `git commit` or `git push --force`
- **SSH host detection** — Auto-detect and refuse commands on production hostnames (`prod`, `production`, `.prod.`, `customer`)
- **Pre-confirmation required** — State-changing remote commands require explicit user approval
- **Idempotent by default** — Scripts use `apt-get install -y --no-upgrade` and similar safe patterns
- **Dry-run support** — Every script supports `--dry-run` for safe preview

## Development

### Isolation

When developing the ai-suite itself, **always install with `--scope global`** — never `--scope project` inside this repository. Using project scope contaminates the source tree with runtime configurations.

### Validation

```bash
# Lint all skill directories
bash enable_suite.sh --verify

# Run individual validation tests
bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh
```

### Adding a New Agent Adapter

1. Create `.ai-suite/layer1-abstraction/agents/<name>/adapter.sh`
2. Implement the adapter interface:
   - `agent_install_project SUITE_DIR PROJECT_DIR`
   - `agent_install_global SUITE_DIR`
   - `agent_uninstall_project PROJECT_DIR`
   - `agent_uninstall_global`
3. Add the agent to `enable_suite.sh` and `disable_suite.sh` flag parsers
4. Validate: `bash enable_suite.sh --verify`

### Adding a New Skill

1. Write a `SKILL.md` file with frontmatter (`description:`, `triggers:`)
2. Place it in the correct tier:
   - **Core** (all agents): `layer3-registry/core/`
   - **Agent-specific**: `layer1-abstraction/agents/<name>/skills/`
   - **Domain-specific**: `layer3-registry/domains/<name>/`
3. Validate: `bash enable_suite.sh --verify`

## Requirements

- **macOS or Linux** (BSD and GNU tools supported via portable helpers)
- **Bash 4+** (or macOS default bash with portable fallbacks)
- **SSH keys** configured for remote host operations (optional)
- **rsync** or **scp** for remote deployment (rsync preferred)

## License

See the repository for license details.
