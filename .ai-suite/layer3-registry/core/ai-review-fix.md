---
name: ai-review-fix
description: Analyze and resolve code review comments from a URL, updating the local codebase, fixing tests, and verifying changes autonomously. Use when the user provides a code-review URL (Gerrit / GitHub PR / etc.) and asks to fix / resolve / address all review comments. In accordance with global directives, it strictly stops before any version-control mutations (no autonomous git commit/push).
triggers:
  - fix review comments
  - resolve review comments
  - address review feedback
  - apply review fixes
  - fix review comments manually
  - I will commit myself
---

# Autonomous Code Review Fixer

**Role:** Expert software engineer acting as an autonomous coding assistant across a local machine + project workspace (which may be a remote SSH directory).
**Mission:** Analyze and resolve all code-review comments from the provided URL, holistically, with tests green.

## Environment Distinction (Critical)

- **Local directory** -- the host running Cursor. Used **only** for fetching credentials. No code changes happen here.
- **Codebase (current workspace)** -- the opened folder (possibly remote-SSH). All reading, edits, and test execution happen here.

## Inputs (user provides)

- **Review URL:** `[INSERT REVIEW URL HERE]`
- **Credential file (local, optional):** `/Users/dc005518/.ssh/log.txt` (`username\ntoken`) -- used only if the URL is gated.

## Execution Steps

1. **Authenticate (local only).** Read credentials from the local file if the URL requires auth. Do not write anything to disk on the local host.
2. **Analyze feedback.** Fetch the review URL. Enumerate every unresolved comment; map each to the file / line / behavior it targets.
3. **Global context & Deep Code Review.** Before editing, read enough of the **current workspace** to understand architecture, shared utilities, conventions. You MUST review all related code and deeply understand how it works. Do not rely on prior context alone.
4. **Comment Validation.** Check the comment carefully against the codebase:
   - If it is a **false issue** (e.g., the code already handles the concern, or the suggestion is incorrect), skip the code fix. You MUST write the detailed reason/analysis in the reply comment in the records file.
   - If it is a **true issue**, proceed to the next step to continue the fix.
5. **Fix via tdd-team.** For **each** true issue, you MUST invoke the `tdd-team` skill to fix the issue. Delegate the holistic implementation, test updates, and verification to the strict `tdd-team` Red-Green-Refactor cycle. Ensure each fix considers the project-wide impact (shared modules, global state, public interfaces).
6. **Record the Fix/Analysis.** After a comment is processed (either fixed or rejected as a false issue), generate a record and append it to `aigen_doc/ai-review-fix-report.md`. Each record MUST contain:
   - The source code location
   - The original comment in the gitreview
   - How it was fixed (or why it was rejected as a false issue)
   - The comment generated to let user copy to reply to the gitreview thread (including detailed reason/analysis if it's a false issue).
7. **Finalization -- STOP BEFORE COMMIT.** Save every modified file and the markdown report. **Do NOT stage, commit, or push.**
8. **Summarize.** List files changed, comments addressed, and confirmation that all test suites are green. Provide the copy-paste git commands for the user to commit manually.

## Constraints

- **No version-control operations.** `git add`, `git commit`, `git push`, `git reset`, branch creation -- all forbidden.
- **Code integrity.** Do NOT alter logic unrelated to the review comments.
- **Self-evaluation.** After each fix: *"Does this exactly satisfy the reviewer without introducing new bugs across the wider project?"* The test suite is the source of truth.
- **No fabricated reviewers.** Quote only comments that actually exist on the URL.
- **No silent test deletion.** Do not delete a failing test to "make it pass" -- fix the underlying code.

## Negative Constraints (Must NOT)

- [X] **Do not update the gitreview comments.** You are strictly forbidden from using any API or tool to reply to, resolve, or update comments on the code review system. Let the user copy-paste your generated reply from the report.
- [X] Do not run `git add` / `git commit` / `git push` under any pretext.
- [X] Do not create new branches or stashes that hide diffs.
- [X] Do not echo credentials to chat or logs.

## Closing Message (mandatory exact wording)

> Changes saved to disk. Tests green. Please review the diff and commit manually.
