# Production Safety Guardrails

> **This file is the source of truth.** `ai-suite enable` deploys this content as
> `.cursor/rules/cursor-suite-production-safety.mdc` with `alwaysApply: true` so
> Cursor enforces it on every task in the workspace. `ai-suite disable` removes
> the deployed copy.

These rules apply to every command, every file edit, and every remote interaction the agent performs in this workspace.

## STRICT RULES: Absolute Safety & Non-Destruction

- **Never execute destructive actions in production environments.**
- **Never run `git commit`, `git push`, or modifying deployment environments without explicit permission.**

## Refuse-by-Default Patterns

The agent MUST refuse and ask for explicit user confirmation before executing any of:

### Shell

- `cat << EOF > file` or `echo "..." > file` for multi-line or UTF-8 file creation -- ALWAYS use the native agent file-writing tool (e.g., `Write` or `StrReplace`) to prevent encoding corruption and escaping bugs.
- `rm -rf /` or `rm -rf $VAR` where `$VAR` is unset / unbound.
- `dd if=... of=/dev/[hs]d*` -- any raw block-device write.
- `mkfs.*` -- filesystem creation on a target the agent did not provision in-session.
- `>` redirect into `/dev/[hs]d*` or `/dev/nvme*`.
- `chmod -R 777 /` or any `chmod -R` on `/`, `/etc`, `/usr`, `/var`.
- `iptables -F`, `nft flush ruleset` on a host not confirmed as a testbed.
- `:(){ :|:& };:` (fork bomb).
- `curl ... | sudo bash` -- pipe-to-shell from untrusted sources.

### Git

- `git commit` -- NEVER autonomously commit changes to the repository. Always pause and ask the user to review and commit manually.
- `git push` / `git push --force` / `git push -f` / `git push --force-with-lease` to `main`, `master`, `release/*`, `prod/*`.
- `git reset --hard` on a branch that has been pushed, without confirming with the user.
- `git branch -D` / `git push origin --delete` of any branch the user did not explicitly name.
- `git filter-branch` / `git filter-repo` / history rewrites on shared branches.
- Skipping hooks with `--no-verify` / `--no-gpg-sign` unless the user asked.

### Remote Hosts (SSH)

- Any command on a hostname matching: `prod`, `production`, `-pr-`, `.prod.`, `release`, `customer`, or a user-supplied blocklist regex.

## Required Behaviors

1. **Explain before destructive ops.** Before any state-changing remote command, state what will change, the rollback recipe, and ask for `yes` confirmation unless the user pre-authorized the session.
2. **Idempotent forms.** Prefer `apt-get install -y --no-upgrade pkg` over `apt-get install pkg`. Prefer `systemctl enable --now svc` over chained start/enable.
3. **Dry-run first.** Where supported (`bazel build --nobuild`, `terraform plan`, `kubectl apply --dry-run=server`), run dry-run and show the diff.
4. **Capture rollback state.** Before mutating remote state, snapshot the relevant config (`cp /etc/X /tmp/X.bak.$(date +%s)`) and record the path.
5. **No secrets in chat or logs.** Redact passwords, API tokens, private keys before quoting.
6. **Scope discipline.** Only edit files in scope of the user\'s task.

## Exceptions

The user may pre-authorize a destructive class of operations for the session by saying explicitly, e.g.:

> "For this session, you're authorized to `git push --force-with-lease` on this PR branch only."

Record that authorization in your reasoning and respect its narrow scope. Do not generalize.

## Verification

If you are uncertain whether a command is safe, the answer is: **stop and ask.** Cost of a question is low. Cost of breaking production is high.
