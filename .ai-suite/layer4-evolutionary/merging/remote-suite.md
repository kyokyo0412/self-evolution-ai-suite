---
name: remote-suite
description: Manage full ai-suite lifecycle across remote SSH hosts (install, collect evolutions, push evolutions, remove). Use when deploying ai-suite remotely, managing remote host suites, or checking remote suite status.
triggers:
  - install ai-suite
  - deploy ai-suite
  - remote ai-suite
  - check ai-suite
  - check ai-suite status
  - remove ai-suite
  - uninstall ai-suite
---

# Remote Suite Lifecycle Manager

Manage ai-suite on remote SSH hosts: install, update, collect evolutions, push evolutions, inspect status, and remove.

## Host Resolution & Safety Preflight
- **Host Extraction**: Extract `--host <user@hostname>`. If missing, prompt user: "Which remote host (`user@hostname`) should ai-suite target?".
- **Production Guard**: If hostname contains `prod`, `production`, `-pr-`, or matches production regex, issue warning and require confirmation.
- **Preflight Check**: Verify `ai-suite` CLI exists locally before execution (`test -f ./ai-suite`).

## Operations
```bash
./ai-suite enable --scope remote --host dev@box1 --agent cursor
./ai-suite enable --scope remote --host user@host1 --agent all --dry-run
./ai-suite evolve collect --host dev@box1
./ai-suite evolve push --host dev@box1
ssh dev@box1 "test -d ~/.cursor/skills && echo 'Installed' || echo 'Not installed'"
./ai-suite disable --scope remote --host dev@box1
```

## Instructions
Execute remote operations via `./ai-suite` CLI preserving scope and agent isolation.

## Negative Constraints (Must NOT)
- [X] **Do not auto-commit**: NEVER run `git commit` or `git push` autonomously. Provide copy-paste git commands.
- [X] **Do not run on prod without confirmation**: Block execution on `prod` or production hosts until confirmed.
- [X] **Do not proceed without host**: Ask which remote host (`user@hostname`) if `--host` is missing.
- [X] **Do not skip dry-run when requested**: Honor `--dry-run` and preview operations.
