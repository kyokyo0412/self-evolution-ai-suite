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

Manage installation, evolution collection/push, read-only status, and removal on explicit SSH targets. Use the existing CLI and installed adapters; do not invent remote APIs or a `status` CLI command.

## Host Resolution & Safety Preflight
- Resolve `--host user@hostname` from the request or established session context. Ask which host if none is available; do not proceed without an explicit target. Never substitute a sample hostname or guess a missing project path.
- Match host safety markers case-insensitively after separating the SSH username. For `prod`, `production`, `-pr-`, `release`, or `customer`, follow workspace production restrictions. For hosts containing `vcenter`, `nsxmgr`, or `nsx-manager`, warn that the target may be a production manager and wait for explicit confirmation before continuing, including read-only status. An existing target-specific confirmation remains valid; never treat elapsed time as approval. Confirmation cannot override a stricter production prohibition.
- Locate the source or installed `ai-suite` launcher and verify it exists. Run its `enable --verify` check before mutation; fail on missing scripts, invalid skills, or broken resource references. Check local Bash, Python 3, SSH, and the chosen `rsync` or `scp` client. Establish authentication without printing credentials. Do not install system dependencies or restart services as part of this skill.
- Before remote mutation, identify the requested agent, scope, deployment path, and project path; inspect current installation state read-only when needed. Preserve custom configurations, native rules, memory, and unresolved merge inputs. Honor `--dry-run`: previews must not execute SSH, synchronization, or target writes.

## Command Building and Defaults

- Supported `--agent` values are `cursor`, `claude`, `codex`, `opencode`, `continue`, `roo-code`, and `all`. The CLI default is `cursor`; honor an explicit or established selection and report the selected value.
- `--scope remote` selects SSH deployment. `--remote-scope global` is the default installed scope. For a project install use `--remote-scope project --project /absolute/project/path`; confirm a missing project path rather than selecting the deployment directory implicitly. `--project` always describes the project on the remote host.
- The default `--remote-path` is the literal remote marker `$HOME/.ai-suite-deploy`, resolved on that host. Quote it locally as `'$HOME/.ai-suite-deploy'`; never expand the local home directory into a remote destination. Honor a supplied path and use the CLI transport serializer for spaces, quotes, or metacharacters. Reject traversal, control characters, invalid identifiers, and invalid flags before side effects; do not construct ad hoc SSH command strings from user input.
- Forward `--domain DOMAIN` only for an explicitly selected, available domain pack. Domain selection is an enable option, not a new flag for disable or evolution. Preserve the current default domain behavior when no filter was supplied.
- For multiple hosts, invoke enable/disable separately for each host; those commands accept one host. Evolution commands support repeated `--host` flags. Keep a per-host result table and do not hide a partial failure. Evolution returns 0 for success/pending review, 3 when all sources/hosts fail, and 10 for partial failure; invalid invocation returns 1. Preserve pending review state even when transport succeeds.

## Operations

| Intent | Operation and verification |
| --- | --- |
| Install/update | `ai-suite enable --scope remote` with resolved flags; inspect its result and verify the chosen agent's instruction/manifest files read-only. |
| Collect | `ai-suite evolve collect --host USER@HOST`; review reports and durable pending inputs before semantic resolution. Existing differing files remain unchanged; collection does not reinstall global agents. |
| Push | `ai-suite evolve push --host USER@HOST`; apply only reviewed local capabilities, preserve unresolved merge input, and record each host's exit status. |
| Status | Use a read-only SSH status probe against the chosen deployment and agent configuration; report missing, installed, or uncertain from observed paths. Do not infer success only from a skills directory. |
| Remove | `ai-suite disable --scope remote` using the matching agent/scope/path. Only manifest-owned artifacts are removed; unknown legacy files and memory remain for explicit migration or cleanup. |

For global status, native instruction paths are `~/.cursorrules`, `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/instructions.md`, `~/.continue/prompts/ai-suite.prompt`, and `~/.roo/.roorules`. Project paths follow the adapter layout under the selected remote project. Verify the corresponding ownership manifest when present. A missing manifest means legacy ownership is uncertain, not permission to delete a directory. Run status probes through the same bounded transport helper used by the CLI; do not open an interactive SSH session.

## Instructions
Resolve intent and authorized targets, perform safety/preflight checks, construct arguments through the CLI, execute only the requested operation, and verify its outcome. Reuse the `evolve-collect` workflow for semantic merge review. On failure, preserve the original configuration and recovery state, report the failed step, and continue unaffected hosts only within the authorized scope. Return host, operation, agent/scope, result, and any pending review or recovery path. Supply copy-paste git commands for manual review when relevant.

## Examples

Hostnames below are reserved examples. Substitute only a target authorized in the request.

```bash
# Preview an install; default remote scope is global.
./ai-suite enable --scope remote --host dev@alpha.example.invalid --agent cursor --dry-run
# Install Claude into an explicit project on the selected remote host.
./ai-suite enable --scope remote --host dev@alpha.example.invalid --agent claude --remote-scope project --project '/work/project alpha' --remote-path '$HOME/.ai-suite-deploy'
# Install all supported agents only when the request selected all.
./ai-suite enable --scope remote --host dev@alpha.example.invalid --agent all
# Collect from multiple hosts; pending conflicts need semantic review.
./ai-suite evolve collect --host dev@alpha.example.invalid --host dev@beta.example.invalid
# Push reviewed changes; partial failures must be reported per host.
./ai-suite evolve push --host dev@alpha.example.invalid --host dev@beta.example.invalid --agent codex
# Read-only status example for an explicitly selected global Codex installation.
ssh -o BatchMode=yes -o ConnectTimeout=15 dev@alpha.example.invalid 'test -f "$HOME/.codex/AGENTS.md" && test -f "$HOME/.codex/.ai-suite-manifest.json"'
# Remove the matching global install while retaining unowned files and memory.
./ai-suite disable --scope remote --host dev@alpha.example.invalid --agent codex
```

## Negative Constraints (Must NOT)
- [X] **Do not auto-commit**: NEVER run `git commit` or `git push` autonomously. Provide copy-paste git commands.
- [X] **Do not bypass host safety**: Enforce production prohibitions and the explicit confirmation gate for manager-like hosts; never perform destructive production actions.
- [X] **Do not proceed without host**: Ask which remote host (`user@hostname`) if `--host` is missing.
- [X] **Do not skip dry-run when requested**: Honor `--dry-run` and preview operations.
- [X] **Do not invent scope or targets**: Preserve the selected host, agent, domain, deployment path, and project; do not invert collect and push.
- [X] **Do not hide partial failure**: Report failures, uncertain status, and pending semantic merges; do not claim success from a dry-run or delete recovery inputs.
