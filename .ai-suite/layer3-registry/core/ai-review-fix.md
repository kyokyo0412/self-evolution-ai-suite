---
name: ai-review-fix
description: Resolve verified code-review comments locally through tested changes and a resolution report. Use when fixing review comments from one or more Gerrit, GitHub PR, or git-review URLs.
triggers:
  - fix review comments
  - resolve review comments
  - address review feedback
  - apply review fixes
  - fix multiple review urls
  - batch review fix
---
# Code Review Fixer

## Execution Workflow

1. Inspect workspace status and review instructions. Preserve user edits. Use an isolated worktree when needed; never automatically stash, cherry-pick, or overwrite unrelated work.
2. For each review URL, read the requested review through available connectors or authenticated tooling. Obtain credentials only from the explicitly configured credential provider; never assume a personal home path or scan unrelated logs for secrets.
   Use supported parallel tool calls for independent context gathering; keep dependent edits and verification sequential.
3. Verify each comment against the actual code. Record false positives and their supporting evidence.
4. Use the applicable `tdd-team` Red-Green-Refactor workflow for verified behavior defects. Run relevant tests and available linters, and preserve formatting outside changed lines.
5. Prepare reviewed local edits and a resolution report in `aigen_doc/ai-review-fix-report.md` with URL, source revision/hash, location, finding, patch or diff, fix, suggested reply, and validation evidence.
6. Report commands, observed results, unresolved items, and verification limits. Leave commits, pushes, and posting replies to the user.

## Constraints & Quality Bar

- Session and repository no-commit rules take precedence over skill instructions. Never execute `git commit` or `git push`.
- **Strict Resource Lifecycle**: Use `defer`, context managers, `finally`, or shell EXIT traps to clean resources and temporary fixtures.
- Distinguish missing verification from passing checks; never claim that unexecuted tests passed.

## Negative Constraints (Must NOT)

- [X] Do not commit, push, post review comments, or mutate remote reviews automatically.
- [X] Do not damage existing branches, overwrite user edits, or delete meaningful failing tests.
- [X] Do not expose credentials in chat, process arguments, reports, or logs.
- [X] Do not reformat unchanged lines or leave whitespace-only blank lines.
