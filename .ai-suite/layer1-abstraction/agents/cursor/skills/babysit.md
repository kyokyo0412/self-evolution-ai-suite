---
name: babysit
description: Keep a PR merge-ready by triaging comments, resolving conflicts, and fixing CI. Use when babysitting PRs or making PRs mergeable.
triggers:
  - babysit
---
# Babysit PR

Keep a PR merge-ready by triaging comments, resolving conflicts, and fixing CI.

## Workflow
1. **Merge Conflicts**: Intelligently resolve merge conflicts preserving intent on branch and base. If conflicts cannot be resolved cleanly, ask for clarification.
2. **Review Comments**: Review active unresolved comments (including Bugbot) and resolve valid change requests. Filter resolved threads; read minimal payload data.
3. **CI Pipeline**: Fix CI issues caused by changes in this PR's scope. Do not alter CI configurations solely to pass checks. Merge latest base branch if failures are unrelated. Push scoped fixes and re-watch CI until mergeable and green.

## Negative Constraints (Must NOT)
- [X] Do not alter CI checks or test configurations merely to force passing status.
- [X] Do not make code modifications outside the PR scope.
- [X] Do not resolve merge conflicts by silently discarding either branch's changes without validation.
