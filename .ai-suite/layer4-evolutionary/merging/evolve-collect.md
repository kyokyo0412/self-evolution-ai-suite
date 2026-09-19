---
name: evolve-collect
description: Collect and push ai-suite evolutions between remote SSH hosts and local git repo. Use when collecting evolution, syncing reflection, or pulling/pushing remote suite updates.
triggers:
  - collect evolution
  - sync reflection
  - pull suite changes
  - evolve collect
  - collect remote
  - push evolution
  - sync remote reflection
  - gather remote updates
  - deploy evolution
  - update remote with suite
  - collect cursor suite
  - fetch remote reflection
---

# Evolve Collect -- Remote Evolution Sync Skill

Orchestrate the **collect -> review -> push** cycle for ai-suite evolutions between remote SSH hosts and the local git repository.

## Core Evolution Principles
- **Semantic Understanding**: Deep semantic analysis of prompts, skills, and rules.
- **Agent Effectiveness**: Improve prompt processing and reasoning.
- **End-User Usability**: Keep workflows simple, clear, and actionable.
- **Isolation**: When pulling evolution for an AI suite project, the evolution MUST be integrated into the AI suite being developed AND the Augmented Agent.

## Instructions

Act as the evolution sync coordinator:

### Step 1 -- Parse Intent & Host
- **sub-command**: `collect` (default) or `push`.
- **hosts**: Extract `USER@HOST`. If none found, **ask for host**: "Which remote host should I collect from? (format: `user@hostname`)".
- **remote-path**: Optional target directory (`--remote-path PATH`).
- **remote-scope**: `project` or `global` (default: global).
- **dry-run**: Append `--dry-run` if user requests preview or dry run.

### Step 2 -- Build and Execute Command

```bash
# Collect from single or multiple hosts
bash ai-suite evolve collect --host "alice@dev.example.com" [--dry-run]
# Push evolved suite back to remote host
bash ai-suite evolve push --host "alice@dev.example.com" [--remote-scope project]
```

### Step 3 -- Present Evolution Report & Safety
- **Collect**: Display contents of the evolution report or diff from `.ai-suite/layer4-evolutionary/reflection/evolutions/`. Print copy-paste git commands verbatim. Explicitly instruct: "Review the diff before running git commands. Do not auto-commit."
- **Push**: Confirm updated hosts and report status.

## Safety & Constraints
- **Never auto-commit**: AI must not run `git commit` or `git push` automatically. Always leave git commit execution to the user.
- **Host verification**: `--host is required`; ask for host if missing.

## Negative Constraints (Must NOT)
- [X] **Do not auto-commit**: Never run `git commit` or `git push` automatically.
- [X] **Do not proceed without host**: `--host is required`; ask for host if none provided.
- [X] **Do not omit evolution report**: Always present the evolution report or diff to the user.
- [X] **Do not invert commands**: Never run `push` when `collect` was requested.
- [X] **Do not hide dry-run**: Explicitly state when `--dry-run` preview is active.
