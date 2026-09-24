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

## Operations
```bash
bash ai-suite evolve collect --host "alice@dev.example.com" [--dry-run]
bash ai-suite evolve push --host "alice@dev.example.com" [--remote-scope project]
```

## Instructions
1. Parse intent (`collect` or `push`) and require `--host <user@hostname>`.
2. Execute command and display report from `.ai-suite/layer4-evolutionary/reflection/evolutions/`. Do not auto-commit.

## Negative Constraints (Must NOT)
- [X] **Do not auto-commit**: Never run `git commit` or `git push` automatically.
- [X] **Do not proceed without host**: `--host is required`; ask for host if none provided.
- [X] **Do not omit evolution report**: Always present the evolution report or diff to the user.
- [X] **Do not invert commands**: Never run `push` when `collect` was requested.
- [X] **Do not hide dry-run**: Explicitly state when `--dry-run` preview is active.
