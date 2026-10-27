# Production Safety Guardrails

Rules applying to all commands, file edits, and remote interactions.

## Strict Rules
- **Non-Destruction**: Never execute destructive actions in production environments.
- **Git Safety**: Never run `git commit` or `git push` autonomously. Leave git commit execution to the user. Review aliases such as `git review` or `git pushreview` as pushes, not harmless local checks.
- **Authorization**: Deployments and external writes require authorization for the concrete action and target. Reuse authorization already established by the request or session; a skill cannot supply it or override a production prohibition. Read-only review does not authorize mutation.

## Refuse-by-Default Patterns
- Shell: `cat << EOF > file` (use available native agent file tools), `rm -rf /` or unbound `$VAR`, `dd`, `mkfs.*`, raw block redirects, `chmod -R 777 /`, fork bombs.
- Git: `git commit`, force pushing (`git push -f`), hard resets on pushed branches, branch deletion without confirmation, `--no-verify`.
- Remote: Any destructive or mutating command on hosts matching `prod`, `production`, `-pr-`, `release`, `customer`.

## Required Behaviors
1. **Explain First**: State changes and rollback plan before destructive ops.
2. **Idempotence & Dry-run**: Prefer bounded, repeatable operations and use `--dry-run` where supported. A package-install flag does not grant permission to install dependencies or alter a host.
3. **Snapshot State**: Capture config baseline before mutating.
4. **No Secrets**: Redact credentials in chat and logs.
5. **Secret Transport**: Use supported protected credential stores or environment inputs, with tracing disabled. Keep passwords and tokens out of process arguments, URLs, source files, and generated reports. Keep TLS certificate verification enabled; configure a trusted lab CA instead of bypassing it.
6. **Process Ownership**: Use supported job/session tools with finite timeouts and captured exit status. Keep unique task-owned artifacts and recovery inputs; do not kill a process or delete files solely from a stale PID or name pattern.

## Negative Constraints (Must NOT)
- [X] **Do not execute destructive operations in production**: Never run unconfirmed deletions in production.
- [X] **Do not run git commit autonomously**: Always leave git commit execution to the user.
- [X] **Do not force push to protected branches**: Never run git push -f on main, master, release/*, prod/*.
- [X] **Do not create files with cat or echo heredocs**: Use native agent file tools available in the current environment.
- [X] **Do not expose credentials or secrets**: Redact all passwords and tokens.
