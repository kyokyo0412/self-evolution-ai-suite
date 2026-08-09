---
name: ai-review-fix-manual
description: Analyze and resolve code review comments from a URL, updating the local codebase and fixing tests, but stop strictly before any git commit/push so the user can review and commit manually. Use when the user provides a code-review URL and says "fix the comments but I will commit myself", "do not push", "manual review", or similar.
triggers:
  - fix review comments manually
  - I will commit myself
  - do not push
  - manual commit
---

# Autonomous Code Review Fixer — Manual-Commit Variant

Identical to `ai-review-fix` with **one strict additional constraint**: under no circumstances may you run `git add`, `git commit`, `git push`, or any version-control mutation. The user manually generates the commit message in Cursor and pushes.

## Inputs (user provides)

- **Review URL:** `[INSERT REVIEW URL HERE]`
- **Credential file (local, optional):** `/Users/dc005518/.ssh/log.txt`

## Execution Steps

1. **Authenticate (local only).** Read credentials from the local file if the URL is gated.
2. **Analyze feedback.** Enumerate every unresolved comment on the review URL.
3. **Global context.** Read the current workspace to understand architecture and conventions before editing.
4. **Holistic implementation.** Apply changes to the current workspace, considering project-wide impact.
5. **Update unit tests.** Add / modify UTs for the new behavior. Exception: if the review targets test code itself, do not write meta-tests.
6. **Verify & iterate.** Run the relevant test suite. Loop autonomously until green.
7. **Finalization — STOP BEFORE COMMIT.** Save every modified file. **Do NOT stage, commit, or push.**
8. **Summarize.** List files changed, comments addressed, confirm the test suite is green.

## Hard Constraints

- **No version-control operations.** `git add`, `git commit`, `git push`, `git reset`, branch creation — all forbidden.
- **Code integrity.** Do NOT touch unrelated logic.
- **Self-evaluation.** After each fix: *"Does this exactly satisfy the reviewer without breaking the wider project?"* The test suite is the source of truth.
- **Efficiency & Performance**: Maximize parallel tool calls whenever independent tasks can be run concurrently (e.g., executing parallel linters, reading multiple files) to improve AI agent execution efficiency.
- **Quality Check**: Use `ReadLints` or specific automated checking tools after code modifications to maintain a high standard of product developing quality.

## Closing Message (mandatory exact wording)

> Changes saved to disk. Tests green. Please review the diff and commit manually.

## Negative Constraints (Must NOT)

- ❌ Do not run `git add` / `git commit` / `git push` under any pretext.
- ❌ Do not create new branches or stashes that hide diffs.
- ❌ Do not echo credentials to chat or logs.
