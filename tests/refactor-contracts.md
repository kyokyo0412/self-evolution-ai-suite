# Architecture Contract: .ai-suite/ refactored structure
# Phase 2 artifact - defines the directory layout, adapter interface,
# script flag contracts, and skill classification rules.
# Contract tests in test-refactor-contracts.sh verify all of these.

## Directory Structure Contracts

  D1. Root suite dir: .ai-suite/  (NOT .cursor-suite/)
  D2. Flat skill directories replaced by three tiers:
        .ai-suite/layer3-registry/core/           - agent-agnostic, domain-agnostic skills
        .ai-suite/layer1-abstraction/agents/cursor/skills/  - Cursor-IDE-specific skills
        .ai-suite/layer1-abstraction/agents/claude/         - Claude Code adapter (no skills, adapter only)
        .ai-suite/layer3-registry/domains/custom_domain/skills/ - CustomDomain domain skills
  D3. Template directories follow the same tier split:
        .ai-suite/layer2-cognitive/templates/
        .ai-suite/layer3-registry/domains/custom_domain/templates/
  D4. Meta scripts stay at .ai-suite/layer4-evolutionary/validation/  (paths updated inside)
  D5. .cursor-suite/ MUST NOT exist after migration

## Skill Classification Rules

  SC1. A skill belongs in core/ if its description and body contain ZERO
       references to: ".cursorrules", "Cursor", "cursorrules", "~/.cursor"
       (case-insensitive exact tokens - incidental generic refs like
       "cursor" in "cursor position" are not violations).
  SC2. A skill belongs in layer1-abstraction/agents/cursor/ if its description explicitly
       references Cursor-specific APIs (.cursorrules, Cursor skills,
       Cursor settings, ~/.cursor/).
  SC3. A skill belongs in domains/custom_domain/ if its description references
       CustomDomain-specific systems: Custom, Custom, VIB, infravisor, unified-lb,
       , vmkernel, Bazel+deb+VIB.
  SC4. Every skill file MUST still pass validate-suite.sh after migration.

## Core Skills (6 files)

  CS1. tdd-team.md          - description must NOT contain "Custom" or "Bazel"
  CS2. autonomous-team.md   - clean, no domain refs
  CS3. codebase-deepdoc.md  - clean, no domain refs
  CS4. ai-review-fix.md     - clean
  CS5. ai-review-fix-manual.md - clean
  CS6. evolve-collect.md    - must reference "ai-suite" not "cursor-suite"

## Agent Skills (2 files)

  AS1. layer1-abstraction/agents/cursor/skills/ai-suite-architect.md
  AS2. layer1-abstraction/agents/cursor/skills/prompt-developer.md

## Domain Skills (4 files)

  DS1. domains/custom_domain/skills/custom-skill-1.md
  DS2. domains/custom_domain/skills/testbed-setup.md
  DS3. domains/custom_domain/skills/unified-lb-testbed.md
  DS4. domains/custom_domain/skills/bazel-deb-deps.md

## Agent Adapter Interface

  Each adapter lives at .ai-suite/layer1-abstraction/agents/<name>/adapter.sh
  A cursor adapter is at .ai-suite/layer1-abstraction/agents/cursor/adapter.sh
  A claude adapter is at .ai-suite/layer1-abstraction/agents/claude/adapter.sh

  Each adapter MUST define these shell functions (sourced by enable/disable):
    agent_install_project SUITE_DIR PROJECT_DIR   - install for a project
    agent_install_global  SUITE_DIR               - install globally
    agent_uninstall_project PROJECT_DIR           - remove from project
    agent_uninstall_global                        - remove globally

## ai-suite enable Contract Additions

  E1. --agent AGENT flag accepted; AGENT in: cursor | claude | all
      Default: cursor (backward-compat)
  E2. --domain DOMAIN flag accepted; DOMAIN in: custom_domain | none
      Default: none
  E3. --agent all: installs for all supported agents in sequence
  E4. --agent unknownagent: exits 1 with "Unsupported agent" message
  E5. --domain custom_domain: additionally deploys domains/custom_domain/skills/ alongside core
  E6. Existing --scope project | global | remote flags unchanged
  E7. Existing --host, --remote-path, --dry-run, --verify flags unchanged

## Claude Adapter Output Contract

  CL1. Project scope: writes/updates CLAUDE.md in PROJECT_DIR
  CL2. Global scope:  writes/updates ~/.claude/CLAUDE.md
  CL3. CLAUDE.md MUST contain:
         - Section header "## AI Suite Skills"
         - Name + one-line description for every core skill
         - Reflection Protocol trigger phrase
  CL4. CLAUDE.md uses an idempotent sentinel block so re-running
       enable adds no duplicates
  CL5. Disable removes only the sentinel block; leaves other CLAUDE.md
       content intact

## validate-suite.sh Updated Contract

  V1. With no args, scans:
        .ai-suite/layer3-registry/core/
        .ai-suite/layer1-abstraction/agents/cursor/skills/
        .ai-suite/layer3-registry/domains/custom_domain/skills/
  V2. With a path arg, scans that path (unchanged behaviour)
  V3. Total expected pass count: 12 skills x 3 checks = 36 passes
