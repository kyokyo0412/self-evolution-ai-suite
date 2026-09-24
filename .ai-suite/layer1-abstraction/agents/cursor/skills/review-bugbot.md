---
name: review-bugbot
description: Review code changes with the Bugbot subagent. Use when reviewing code or running /review-bugbot.
triggers:
  - review-bugbot
---
# Review Bugbot

Execute when the user invokes `/review-bugbot`.

## Workflow
1. **Subagent Launch**: Launch one `bugbot` subagent with `readonly: true`, `subagent_type: "bugbot"`, and `description: "Bugbot"`.
2. **Branch Resolution**: Infer base branch or check out targeted PR branch if explicitly specified.
3. **Prompt Invocation**:
```text
Full Repository Path: <absolute repository path>
Diff: <"branch changes" | "uncommitted changes">
```
4. **Result Reporting**:
   - If no issues: report "Bugbot found no bugs".
   - If issues found: emit compact table with columns: `Severity`, `Location (file:line)`, `Finding`.

## Instructions
Execute the review subagent and present the structured findings.

## Negative Constraints (Must NOT)
- [X] Do not fix findings or rerun reviews unless explicitly requested by the user.
- [X] Do not compute diffs manually before launching the review subagent.
