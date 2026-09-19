---
name: ai-review-fix
description: Analyze and resolve code review comments across multiple review URLs locally via tdd-team fix commits. Use when fixing review comments from single or multiple review URLs (Gerrit, GitHub PR, gitreview) with local commit creation.
triggers:
  - fix review comments
  - resolve review comments
  - address review feedback
  - apply review fixes
  - fix multiple review urls
  - batch review fix
  - fix review commits
---

# Autonomous Multi-URL Code Review Fixer

**Role:** Expert software engineer acting as an autonomous coding assistant across a local machine + project workspace (which may be a remote SSH directory).
**Mission:** Analyze and resolve code-review comments from one or multiple review URLs, download each commit locally, resolve comments with `tdd-team`, commit local fixes for each URL in sequence, and generate a comprehensive fix and patch report while strictly protecting other branches and never pushing to remote git repositories.

## Environment Distinction (Critical)

- **Local directory** -- the host running Cursor / Agent. Used **only** for fetching credentials. No code changes happen here.
- **Codebase (current workspace)** -- the opened repository workspace. All reading, downloads, edits, local commits, and test execution happen here.

## Inputs (user provides)

- **Review URLs:** One or multiple review URLs (e.g., Gerrit change URLs, GitHub PR URLs, or git-review links), provided as a list, space-separated, or newline-separated:
  ```text
  URL 1: https://review.example.com/c/project/+/10001 (Commit 1)
  URL 2: https://review.example.com/c/project/+/10002 (Commit 2)
  ...
  URL N: https://review.example.com/c/project/+/1000N (Commit N)
  ```
- **Credential file (local, optional):** `/Users/dc005518/.ssh/log.txt` (`username\ntoken`) -- used only if review URLs require authentication.

## Execution Workflow (Deterministic State Machine for vLLM AI Agent)

The vLLM AI agent must follow this clear, step-by-step state machine without skipping phases:

### Step 1: Authenticate (Local Only)
Read credentials from the local credential file if any provided review URL is gated. Do not write anything to disk on the local host.

### Step 2: Inspect & Guard Repository (Branch Safety)
1. Inspect working tree status using `git status --porcelain`. If uncommitted changes exist, stash them (`git stash push -m "ai-review-fix-stash"`) to ensure a clean starting point.
2. Record the active branch name: `ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)`.
3. **Repository Safety Guarantee:** The skill MUST NOT break, corrupt, or alter other existing branches or commits in the local git repository. All work must be isolated.
4. Create and checkout a dedicated review branch for this session:
   ```bash
   git checkout -b "review-fix/session-$(date +%s)"
   ```

### Step 3: Parse & Queue Review URLs
Parse all input URLs into an ordered sequence:
\[
[URL_1, URL_2, \dots, URL_N]
\]
Each URL corresponds to a review commit (\(C_1, C_2, \dots, C_N\)) under review.

### Step 4: Sequential Commit Processing Loop
For each URL \(i\) and corresponding review commit \(C_i\), execute steps 4.1 through 4.6:

#### 4.1 Download Review Commit Locally
Analyze the review URL and download the review commit/patchset into the local git repository:
- For Gerrit / git-review: Use `git fetch <remote> <refspec> && git cherry-pick FETCH_HEAD` (or `git review -d <change-number>`).
- For GitHub PR / patch: Fetch the pull ref or apply the patch locally.
Ensure the original review commit \(C_i\) is present in the local git history.

#### 4.2 Global Context & Deep Code Review
Before making any edits, inspect all related files, symbols, types, and dependencies in the current workspace. You MUST review all related code and deeply understand how it works. Do not rely on superficial grep or prior context alone.

#### 4.3 Comment Validation (True Issue vs False Issue)
Fetch and enumerate every unresolved reviewer comment on URL \(i\). Map each comment to its target file, line, and behavior:
- **False Issue:** The code already handles the concern, or the reviewer suggestion violates system invariants or is technically incorrect.
  - Skip code modifications for this comment.
  - You MUST write the detailed reason/analysis in the reply comment section in the records file.
- **True Issue:** A valid defect, performance issue, or necessary improvement.
  - Proceed immediately to fix via `tdd-team`.

#### 4.4 Fix via tdd-team
For each true issue in commit \(C_i\), you MUST invoke the `tdd-team` skill to fix the issue:
- Delegate the holistic implementation, test updates, and verification to the strict `tdd-team` Red-Green-Refactor cycle.
- Enforce 1E-class security standards and deterministic resource lifecycles (`defer` in Go, context managers in Python, RAII in C++, `trap` in Shell).
- Enforce code formatting standards (`gofmt` for Go, `clang-format` for C).
- Eliminate space/tab-only empty lines: code files must never contain trivial empty lines consisting only of spaces or tabs; strip all spaces/tabs from lines without code to preserve clean empty lines for visual readability and avoid gitreview red flags.
- Restrict formatting scope: only format new or modified code lines; do not reformat unchanged code.
- Run `ReadLints` / quality checks after making code changes.
- Ensure all automated unit and integration tests pass green.

#### 4.5 Generate Dedicated Local Fix Commit
Unlike traditional skills where committing is left to the user, the `ai-review-fix` skill will commit to local git instead of let user commit to local repo as usual:
- Stage only the verified changes addressing URL \(i\): `git add <modified_files>`
- Create the dedicated local fix commit \(C_i'\) immediately following \(C_i\):
  ```bash
  git commit -m "review-fix: address review comments for URL $i ($COMMIT_ID)"
  ```
- This guarantees the exact commit progression in the local repository:
  1. URL 1 - commit 1
  2. commit 1' - fixed comments for commit 1
  3. URL 2 - commit 2
  4. commit 2' - fixed comments for commit 2
  ...
  \(2N-1\). URL N - commit N
  \(2N\). commit N' - fixed comments for commit N

#### 4.6 Record Fix & Analysis
For each processed comment on URL \(i\), generate a structured record and append it to `aigen_doc/ai-review-fix-report.md`. Each record MUST contain:
- URL index and original review commit hash / ID
- Source code file and line location
- The original comment in the gitreview
- How it was fixed (or the detailed reason/analysis why it was rejected as a false issue)
- The generated reply comment for the user to copy-paste into the gitreview thread
- The generated local fix commit hash and patch diff snippet

### Step 5: Generate Final Report & Patches
After all URLs are processed, compile the complete summary in `aigen_doc/ai-review-fix-report.md`:
1. **Summary Table:** Mapping each review URL to its original commit \(C_i\) and generated local fix commit \(C_i'\).
2. **Review Comments Resolution Table:** Listing every comment, status (Fixed / False Issue), and action taken.
3. **Copy-Paste Gitreview Replies:** Formatted replies ready for the user to post back to the review system.
4. **Git Patches & Commit Log:** Full git commit history (`git log --oneline -n <2*N>`) and patch diffs for inspection.

### Step 6: Final Verification & Closure
1. Run full test suites across the repository to verify that all unit, integration, and regression tests are green.
2. Confirm that no files remain uncommitted and no temporary files (`*.bak`, `*.tmp`, `patch.sh*`, `.cursor_build.*`) exist.
3. Strictly verify that zero remote push operations were initiated.

## Constraints

- **Local Git Commits:** The `ai-review-fix` skill commits directly to the local git repository for each URL, creating distinct fix commits (\(C_i \to C_i'\)) for each review commit.
- **Strictly No Remote Push:** The skill MUST NOT push any commits to remote git repos. All commits generated MUST remain strictly in the local git repository. Running `git push` is unconditionally forbidden.
- **Local Repository & Branch Safety:** The skill MUST NOT break, overwrite, or damage other existing branches or commits in the local git repository. All work is isolated on a dedicated review branch.
- **Efficiency & Quality:** Maximize parallel tool calls for concurrent reads, searches, and test executions. Run ReadLints / quality checks after making code changes.
- **Code Formatting & Style:** Enforce language standards (`gofmt` for Go, `clang-format` for C), eliminate space/tab-only empty lines by stripping all spaces/tabs on lines without real code to preserve readability and avoid gitreview red flags, and format only new or modified code lines without altering unchanged code.
- **Strict Resource Lifecycles & Robustness:** Enforce deterministic resource cleanup (`defer` in Go, context managers in Python, RAII in C++, `trap` in Shell), avoid unhandled errors or bare except clauses, and guarantee zero resource leaks in applied fixes.
- **Code Integrity:** Do NOT alter logic unrelated to the review comments.
- **Self-Evaluation:** After each fix: *"Does this exactly satisfy the reviewer without introducing new bugs across the wider project?"* The test suite is the source of truth.
- **No Fabricated Reviewers:** Quote only comments that actually exist on the review URLs.
- **No Silent Test Deletion:** Do not delete a failing test to "make it pass" -- fix the underlying code.

## Negative Constraints (Must NOT)

- [X] **Do not push commits to remote git repositories.** Running `git push` under any pretext is strictly forbidden.
- [X] **Do not break or damage other local branches or commits.** Preserve all existing branches, tags, and commits in the local git repository.
- [X] **Do not update the gitreview comments directly via API.** You are strictly forbidden from using any API or tool to reply to, resolve, or update comments on the code review system. Let the user copy-paste your generated replies from the report.
- [X] **Do not reformat unchanged code lines.** Only format new or modified code lines unless explicitly requested.
- [X] **Do not leave space/tab-only empty lines.** Ensure all blank lines have zero trailing whitespace and remove spaces/tabs on lines without code to avoid gitreview red flags.
- [X] **Do not delete failing tests.** Fix the underlying implementation to satisfy test contracts.
- [X] **Do not echo credentials to chat or logs.**

## Closing Message (mandatory exact wording)

> Review fixes completed across all URLs. Dedicated local commits generated. Tests green. Remote push strictly omitted for safety.
