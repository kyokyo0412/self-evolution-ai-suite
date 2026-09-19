# Production Safety Guardrails

These rules apply to every command, file edit, and remote interaction performed in this workspace.

## STRICT RULES: Absolute Safety & Non-Destruction
- **Never execute destructive actions in production environments.**
- **Never run `git commit`, `git push`, or modifying deployment environments without explicit permission.**

## Refuse-by-Default Patterns
Ask explicit confirmation before executing:

### Shell
- `cat << EOF > file` or `echo "..." > file` for multi-line or UTF-8 file creation -- ALWAYS use the native agent file-writing tool (e.g., `Write` or `StrReplace`) to prevent encoding corruption and escaping bugs.
- `rm -rf /` or `rm -rf $VAR` where `$VAR` is unset/unbound.
- `dd if=... of=/dev/[hs]d*`, `mkfs.*`, or `>` redirect into `/dev/[hs]d*` or `/dev/nvme*`.
- `chmod -R 777 /` or on `/`, `/etc`, `/usr`, `/var`.
- `iptables -F`, `nft flush ruleset` on unconfirmed hosts.
- `:(){ :|:& };:` (fork bomb), `curl ... | sudo bash`.

### Git
- `git commit` -- NEVER autonomously commit changes to the repository. Always pause and ask the user to review and commit manually.
- `git push` / `git push --force` / `git push -f` / `git push --force-with-lease` to `main`, `master`, `release/*`, `prod/*`.
- `git reset --hard` on pushed branches without confirmation.
- `git branch -D` / `git push origin --delete` of branches not explicitly named by user.
- `git filter-branch` / `git filter-repo` on shared branches.
- Skipping hooks with `--no-verify` / `--no-gpg-sign`.

### Remote Hosts (SSH)
- Any command on host matching: `prod`, `production`, `-pr-`, `.prod.`, `release`, `customer`.

## Required Behaviors
1. **Explain before destructive ops**: State changes, rollback plan, and request confirmation.
2. **Idempotent forms**: Prefer `apt-get install -y --no-upgrade pkg`; `systemctl enable --now svc`.
3. **Dry-run first**: Use dry-run (`terraform plan`, `kubectl apply --dry-run=server`) where supported.
4. **Capture rollback state**: Snapshot config before mutating (`cp /etc/X /tmp/X.bak.$(date +%s)`).
5. **No secrets in chat or logs**: Redact credentials before quoting.
6. **Scope discipline**: Only edit files within task scope.

## Negative Constraints (Must NOT)
- [X] **Do not execute destructive operations in production**: Never run unconfirmed deletions in production.
- [X] **Do not run git commit autonomously**: Always leave git commit execution to the user.
- [X] **Do not force push to protected branches**: Never run git push -f on main, master, release/*, prod/*.
- [X] **Do not create files with cat or echo heredocs**: Always use native agent file tools (Write or StrReplace).
- [X] **Do not expose credentials or secrets**: Redact all passwords and tokens.
