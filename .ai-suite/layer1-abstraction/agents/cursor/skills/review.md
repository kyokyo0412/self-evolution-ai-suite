---
name: review
description: Review code changes with Bugbot or Security Review subagents. Use when choosing between bug or security reviews.
disable-model-invocation: true
triggers:
  - review
---
# Review

Ask the user which review subagent to run using `AskQuestion` (or prompt directly if unavailable). Single-select options:
- `bugbot`: Bugbot (`/review-bugbot`)
- `security`: Security Review (`/review-security`)

Upon selection, invoke the matching review workflow once.

## Instructions
Execute the selected review workflow following `/review-bugbot` or `/review-security`.

## Negative Constraints (Must NOT)
- [X] Do not run reviews without user selection if choice is ambiguous.
- [X] Do not modify reviewed code during the review phase.
