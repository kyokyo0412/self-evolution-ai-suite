---
name: review-security
description: Review code changes for security vulnerabilities with Security Review subagent. Use when running /review-security.
triggers:
  - review-security
---
# Review Security

Execute when the user invokes `/review-security`.

## Workflow
1. **Capability Check**: Inspect available security review tools and their actual schemas. Use a named Security Review subagent only when the host exposes it; do not invent `subagent_type` arguments.
2. **Read-only Scope**: Resolve the requested staged, unstaged or base/head diff without changing branches, staging or user files. Record exact revisions and relevant trust boundaries.
3. **Invocation or fallback**: Supply the supported reviewer with the repository path and diff scope below. If unavailable, disclose the limit and perform a read-only review using `git diff`, source and tests; do not label the fallback as a named subagent execution.
```text
Full Repository Path: <absolute repository path>
Diff: <"branch changes" | "uncommitted changes">
```
4. **Result Reporting**:
   - Report scope, actual reviewer used and verification limits. Report no substantiated findings without claiming security certification.
   - If issues found: emit compact table with columns: `Severity`, `Location (file:line)`, `Finding`.

## Instructions
Execute the review subagent and present the structured findings.

## Negative Constraints (Must NOT)
- [X] Do not fix findings or rerun reviews unless explicitly requested by the user.
- [X] Do not modify branches, the index or reviewed code during a read-only review.
- [X] Do not claim a named reviewer ran when it was unavailable.
