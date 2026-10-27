---
name: split-to-prs
description: Split current work into small reviewable PRs. Use when splitting a chat, set of changes, branch, or PR.
triggers:
  - split-to-prs
---
# Split to PRs

Prepare independent, reviewable slices and a concrete manual PR publication plan.

## Workflow
1. **Analyze Working Tree**: Discover the actual default branch and base/head revisions; do not assume `main`. Inspect staged, unstaged, and untracked work and identify slices by behavior and dependency boundaries.
2. **Preserve State**: Record the starting status and preserve user edits and staging. Use isolated worktrees or named patch artifacts for slices; do not auto-stash, switch branches, or create backup refs in the user's working tree.
3. **Prepare Slices**: Build the requested local artifacts with explicit paths and dependency order. For a review-only request, provide the plan without editing. Clarify only scope decisions that cannot be inferred from the request or code.
4. **Validate**: Run relevant verification for each slice against its prerequisites and check the combined result. Disclose a slice that cannot stand alone.
5. **Report**: Provide slice contents, base revisions, evidence, and manual branch/stage/commit/push/PR commands. Report PR URLs only when they actually exist.

## Instructions
Follow the phased split workflow, validating state at each slice.

## Negative Constraints (Must NOT)
- [X] Never execute `git commit` or `git push`; leave publication to the user. Plan approval does not override this boundary.
- [X] Do not open PRs or post externally without explicit authorization.
- [X] Do not discard uncommitted work or execute destructive git operations (`reset --hard`, `clean -fdx`).
- [X] Do not run blanket staging commands like `git add .` or `git add -A`; stage only named files.
