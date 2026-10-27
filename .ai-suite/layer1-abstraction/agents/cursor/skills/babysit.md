---
name: babysit
description: Keep a PR merge-ready by triaging comments, resolving conflicts, and fixing CI. Use when babysitting PRs or making PRs mergeable.
triggers:
  - babysit
---
# Babysit PR

Keep a PR merge-ready by triaging comments, resolving conflicts, and fixing CI.

## Workflow
1. **Scope and state**: Identify the PR, base/head revisions, available authenticated read tools, and dirty worktree state. Use an isolated worktree when needed to preserve user edits; do not switch the user's branch or auto-stash changes.
2. **Review Comments**: Verify unresolved comments against the actual code, fix valid in-scope issues with regression coverage, and report false positives with evidence. Leave posting replies and resolving remote threads to the user unless explicitly authorized.
3. **Conflicts and CI**: Reproduce failures locally where possible. Resolve conflicts while preserving both branches' intent. Investigate unrelated CI failures and report their evidence; do not merge the base merely to hide them.
4. **Handoff**: Run applicable verification, report the resulting diff, remaining failures and commands for user publication. Remote CI for an unpublished local patch remains unverified. Monitor an existing run only with a finite timeout and record its actual outcome.

## Negative Constraints (Must NOT)
- [X] Do not alter CI checks or test configurations merely to force passing status.
- [X] Do not make code modifications outside the PR scope.
- [X] Do not resolve merge conflicts by silently discarding either branch's changes without validation.
- [X] Never execute `git commit` or `git push`; leave publication to the user, including when a lower-level workflow requests it.
- [X] Do not treat missing remote access or unpublished changes as proof that a PR is merge-ready.
