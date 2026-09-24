---
name: split-to-prs
description: Split current work into small reviewable PRs. Use when splitting a chat, set of changes, branch, or PR.
triggers:
  - split-to-prs
---
# Split to PRs

Split a accumulated set of changes into small, reviewable pull requests.

## Workflow
1. **Analyze Working Tree**: Compare against default branch (`main`). Identify natural slices by directory, component, or `CODEOWNERS` boundaries.
2. **Snapshot Working State**: Create a recoverable backup ref (`git stash create`, `git update-ref refs/backup/pre-split-...`).
3. **Propose Plan**: Present slice boundaries with branch names, target diff scopes, and dependency sequence. Await user confirmation before mutating git state.
4. **Execute**: Create feature branches, stage and commit specific paths per slice, push, and open PRs.
5. **Report**: Summarize branch names, PR URLs, and remaining local files.

## Instructions
Follow the phased split workflow, validating state at each slice.

## Negative Constraints (Must NOT)
- [X] Do not create branches, commit, push, or open PRs without prior user approval of the plan.
- [X] Do not discard uncommitted work or execute destructive git operations (`reset --hard`, `clean -fdx`).
- [X] Do not run blanket staging commands like `git add .` or `git add -A`; stage only named files.
