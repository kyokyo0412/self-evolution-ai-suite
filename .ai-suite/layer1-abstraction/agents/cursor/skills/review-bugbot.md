---
name: review-bugbot
description: Review code changes with Bugbot when supported. Use when explicitly requesting Bugbot or /review-bugbot; generic code reviews use the applicable core review skill.
triggers:
  - review-bugbot
---
# Review Bugbot

Execute when the user invokes `/review-bugbot`.

## Workflow
1. **Capability Check**: Inspect available review tools and their actual schemas. Use a named Bugbot subagent only when the host exposes it; do not invent `subagent_type` arguments.
2. **Read-only Scope**: Resolve the requested staged, unstaged or base/head diff without changing branches, staging or user files. Record exact revisions and missing context. Use an isolated workspace if necessary.
3. **Invocation or fallback**: Supply the supported reviewer with the repository path and diff scope below. If unavailable, disclose that limitation and perform a read-only review using `git diff` and relevant source/tests; do not label the fallback result as a Bugbot execution.
```text
Full Repository Path: <absolute repository path>
Diff: <"branch changes" | "uncommitted changes">
```
4. **Result Reporting**:
   - Report inspected scope, verification limits and actual reviewer used. If no findings are substantiated, report that result without certifying the absence of bugs.
   - If issues found: emit compact table with columns: `Severity`, `Location (file:line)`, `Finding`.

## Instructions
Execute the review subagent and present the structured findings.

## Negative Constraints (Must NOT)
- [X] Do not fix findings or rerun reviews unless explicitly requested by the user.
- [X] Do not modify branches, the index or reviewed code during a read-only review.
- [X] Do not claim a named reviewer ran when it was unavailable.
