# Architecture Contract: .cursor-suite/skills/evolve-collect.md
# Phase 2 artifact -- defines frontmatter, section structure, and behaviour
# constraints for the new AI skill.
# Contract tests in test-evolve-collect-contracts.sh verify these.

## Skill File Identity

  S1. File path: .cursor-suite/skills/evolve-collect.md
  S2. Frontmatter name: evolve-collect  (equals filename basename, kebab-case)
  S3. Frontmatter description: must contain "Use when" (validator requirement)
  S4. Frontmatter description: must mention "collect" and "remote" and "evolution" or "reflection"
  S5. Frontmatter triggers: must include at least 6 trigger phrases covering:
        - "collect evolution"
        - "sync reflection"
        - "pull suite changes"
        - "evolve collect"
        - "collect remote"
        - "push evolution"  (push sub-command is also handled by this skill)
  S6. Skill passes validate-suite.sh with 0 errors

## Skill Body -- Required Sections

  B1. A "Workflow" or "Instructions" section explaining the collect -> review -> push loop
  B2. A section listing the supported trigger phrases (so the AI knows what activates it)
  B3. A "Command Construction" section showing how to build the ai-suite evolve command:
        - Extract host(s) from user input
        - Extract optional --remote-path
        - Determine --dry-run flag from "preview"/"dry-run"/"what changed" phrases
        - Determine push vs collect from user intent
  B4. A "Safety Constraints" section that MUST state:
        - Never auto-commit
        - Always show the diff/report to the user before presenting git commands
        - Always ask for --host if none is provided in the prompt
  B5. A "Negative Constraints" section listing what the skill must NOT do

## Behavioural Contracts

  BC1. When host IS in the prompt: run ai-suite evolve immediately, no clarification needed.
  BC2. When host IS NOT in the prompt: ask "Which remote host? (format: USER@HOST)" before running.
  BC3. Dry-run keywords: "preview", "dry run", "dry-run", "what changed", "show changes"
       -> always appends --dry-run; never modifies local files.
  BC4. Push keywords: "push", "deploy", "update remote", "send evolution"
       -> runs ai-suite evolve push (not collect).
  BC5. Collect keywords (default): "collect", "sync", "pull", "fetch", "gather"
       -> runs ai-suite evolve collect.
  BC6. After collect completes: always present the evolution report content AND
       the copy-paste git commands. Never skip either.
  BC7. After push completes: confirm which hosts succeeded and which (if any) failed.

## Exit / Size Constraints (enforced by validate-suite.sh)

  V1. name field: "evolve-collect" (matches filename)
  V2. description field: single line, <= 1024 chars, contains "Use when"
  V3. body: <= 600 lines total
