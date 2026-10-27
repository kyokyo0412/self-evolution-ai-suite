---
name: ai-review-bot
description: Review a requested diff or pull request with evidence-grounded findings. Use when reviewing code changes, staged files, git diffs, pull requests, or commit messages.
triggers:
  - ai review
  - ai-review-bot
  - review code
  - review diff
  - review pr
  - senior engineer review
---

# AI Review Bot

## Inputs and authority

Resolve the requested repository, diff or revision, and review question first. The user's selected target takes precedence over a default diff. Review is read-only: do not modify source, the index, commits, or remote reviews. Run fault experiments only in disposable fixtures. Use `ai-review-fix` or the applicable delivery workflow when fixes are explicitly requested.

## Review Workflow

1. Inspect workspace status and project instructions. Select one comparison and record its base/head or working-tree scope:

   | Requested target | Comparison |
   | --- | --- |
   | Staged changes | `git diff --cached` |
   | Unstaged tracked changes | `git diff` |
   | All tracked working changes | `git diff HEAD` |
   | Branch or pull request | `git diff <verified-base>...<verified-head>` |

   Honor explicit file filters. For an unspecified comparison, inspect status and available branch metadata; state a defensible selection or ask when multiple targets materially differ. Identify untracked requested files separately. Never assume `main` exists.
2. Resolve definitions, callers, tests, configuration, and relevant history before reporting. Read-only context can establish impact but findings must identify a regression in the requested target. Respect designated exclusions; inspect lockfiles, generated files, and vendor changes when they are explicit targets or necessary to verify dependency, provenance, or security effects.
3. Apply relevant personas, using actual independent agents only when supported; otherwise conduct clearly labeled review passes:
   - **Senior Engineer:** State integrity, boundaries, resource cleanup, injection, race conditions, error paths, and compatibility.
   - **Commit Message Reviewer:** Match the project's conventions and the diff; do not invent length or prefix requirements.
   - **GitHub Workflow Reviewer:** Permissions, dependency provenance, runner usage, failure propagation, and bounded retries.
   - **Accessibility Reviewer:** Affected interfaces, keyboard access, semantics, and the project's accessibility target.
   - **CL Summarizer:** Explain the concrete behavior change and reason briefly.
4. Test a suspected failure with the smallest safe reproducer or code trace. Security checks are contextual: compare DNS names case-insensitively when their protocol requires it, preserving case-sensitive payloads; trace timing attack oracles through the authentication flow; verify required class guards and credential sources. A rule of thumb alone is insufficient evidence.
5. Perform a final challenge pass: confirm Diff Direction, reachability, user intent, existing protections, and reproducible impact. Removed lines explain context; anchor findings to the changed behavior that remains. Mark unavailable verification rather than inventing results.

## Output and recovery

Give prioritized verified findings with file/line, triggering input or state, observable impact, supporting evidence, and a focused remedy. State comparison scope, commands/results, baseline failures, and verification limits. If no verified finding remains, say so and disclose what could not be checked; do not certify defect freedom.

Example: trace a newly logged value to its source. Report credential exposure only if it can contain a secret; omit a finding for a public identifier. Keep secrets masked in all evidence.

If the target, access, or essential source is missing, complete independent inspection, then report the exact blocker and needed input. Do not broaden scope or repeatedly retry an inaccessible service.

## Negative Constraints (Must NOT)

- [X] Do not mutate repositories, post review comments, commit, or push during a review.
- [X] Do not mix staged and unstaged changes without an explicit all-changes scope.
- [X] Do not report speculative defects, removed code as live behavior, or unrelated pre-existing findings as introduced regressions.
- [X] Do not treat heuristic violations or a passing test as proof of a vulnerability or defect-free software.
