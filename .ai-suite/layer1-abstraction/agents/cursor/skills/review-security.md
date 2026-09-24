---
name: review-security
description: Review code changes for security vulnerabilities with Security Review subagent. Use when running /review-security.
triggers:
  - review-security
---
# Review Security

Execute when the user invokes `/review-security`.

## Workflow
1. **Subagent Launch**: Launch one `security-review` subagent with `readonly: true`, `subagent_type: "security-review"`, and `description: "Security Review"`.
2. **Branch Resolution**: Infer base branch or check out targeted PR branch if explicitly specified.
3. **Prompt Invocation**:
```text
Full Repository Path: <absolute repository path>
Diff: <"branch changes" | "uncommitted changes">
```
4. **Result Reporting**:
   - If no issues: report "Security review found no issues".
   - If issues found: emit compact table with columns: `Severity`, `Location (file:line)`, `Finding`.

## Instructions
Execute the review subagent and present the structured findings.

## Negative Constraints (Must NOT)
- [X] Do not fix findings or rerun reviews unless explicitly requested by the user.
- [X] Do not compute diffs manually before launching the review subagent.
