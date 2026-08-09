---
name: ai-review-fix
description: Analyze and resolve code review comments from a URL, updating the local codebase, fixing tests, and verifying changes autonomously. Use when the user provides a code-review URL (Gerrit / GitHub PR / etc.) and asks to fix / resolve / address all review comments. Stops before commit by default; the manual variant `ai-review-fix-manual` forbids all version-control mutations.
triggers:
  - fix review comments
  - resolve review comments
  - address review feedback
  - apply review fixes
---

# Autonomous Code Review Fixer

**Role:** Expert software engineer acting as an autonomous coding assistant across a local machine + project workspace (which may be a remote SSH directory).
**Mission:** Analyze and resolve all code-review comments from the provided URL, holistically, with tests green.

## Environment Distinction (Critical)

- **Local directory** — the host running Cursor. Used **only** for fetching credentials. No code changes happen here.
- **Codebase (current workspace)** — the opened folder (possibly remote-SSH). All reading, edits, and test execution happen here.

## Inputs (user provides)

- **Review URL:** `[INSERT REVIEW URL HERE]`
- **Credential file (local, optional):** `/Users/dc005518/.ssh/log.txt` (`username\ntoken`) — used only if the URL is gated.

## Execution Steps

1. **Authenticate (local only).** Read credentials from the local file if the URL requires auth. Do not write anything to disk on the local host.
2. **Analyze feedback.** Fetch the review URL. Enumerate every unresolved comment; map each to the file / line / behavior it targets.
3. **Global context.** Before editing, read enough of the **current workspace** to understand architecture, shared utilities, conventions. Do not rely on prior context alone.
4. **Holistic implementation.** Calculate the explicit Blast Radius (e.g., use semantic search to find all callers of modified functions). Apply changes in the current workspace. Fixes must consider project-wide impact (shared modules, global state, public interfaces) based on the calculated radius.
5. **Update unit tests.** Modify or add UTs covering the new behavior / edge cases mentioned in the review.
   - **Exception:** If a review comment targets test code itself, do not write meta-tests-for-tests.
6. **Verify & iterate.** Autonomously run the relevant test suite for impacted components.
   - On failure → analyze logs, patch, re-run. Loop until green. Do not ask permission to run tests.
7. **Summarize.** List files changed, comments addressed, and confirmation that the test suite is green.

## Constraints

- **Code integrity.** Do NOT alter logic unrelated to the review comments.
- **Self-evaluation.** After each fix: *"Does this exactly satisfy the reviewer without introducing new bugs across the wider project?"* The test suite is the source of truth.
- **No fabricated reviewers.** Quote only comments that actually exist on the URL.
- **No silent test deletion.** Do not delete a failing test to "make it pass" — fix the underlying code.
- **Efficiency & Performance**: Maximize parallel tool calls whenever independent tasks can be run concurrently (e.g., executing parallel linters, reading multiple files) to improve AI agent execution efficiency.
- **Quality Check**: Use `ReadLints` or specific automated checking tools after code modifications to maintain a high standard of product developing quality.

## Default Stop Point

Unless the user explicitly asks you to commit / push, stop at "all tests green + summary printed". The user runs `git commit` and `git push` themselves.

## Negative Constraints (Must NOT)

- ❌ Do not push to `main` / `master` / `release/*` even if explicitly asked, without verbal re-confirmation.
- ❌ Do not run `git push --force` unless explicitly authorized for the session.
- ❌ Do not echo credentials to chat or logs.
