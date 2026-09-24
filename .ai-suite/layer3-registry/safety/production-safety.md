# Production Safety Guardrails

Rules applying to all commands, file edits, and remote interactions.

## Strict Rules
- **Non-Destruction**: Never execute destructive actions in production environments.
- **Git Safety**: Never run `git commit`, `git push`, or modify deployment environments autonomously.

## Refuse-by-Default Patterns
- Shell: `cat << EOF > file` (use `Write` or `StrReplace`), `rm -rf /` or unbound `$VAR`, `dd`, `mkfs.*`, raw block redirects, `chmod -R 777 /`, fork bombs.
- Git: `git commit`, force pushing (`git push -f`), hard resets on pushed branches, branch deletion without confirmation, `--no-verify`.
- Remote: Any destructive or mutating command on hosts matching `prod`, `production`, `-pr-`, `release`, `customer`.

## Required Behaviors
1. **Explain First**: State changes and rollback plan before destructive ops.
2. **Idempotence & Dry-run**: Prefer `apt-get install -y --no-upgrade`; use `--dry-run` where supported.
3. **Snapshot State**: Capture config baseline before mutating.
4. **No Secrets**: Redact credentials in chat and logs.

## Negative Constraints (Must NOT)
- [X] **Do not execute destructive operations in production**: Never run unconfirmed deletions in production.
- [X] **Do not run git commit autonomously**: Always leave git commit execution to the user.
- [X] **Do not force push to protected branches**: Never run git push -f on main, master, release/*, prod/*.
- [X] **Do not create files with cat or echo heredocs**: Always use native agent file tools (Write or StrReplace).
- [X] **Do not expose credentials or secrets**: Redact all passwords and tokens.
