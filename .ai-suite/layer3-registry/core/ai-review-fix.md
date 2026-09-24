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

Analyzes and resolves code-review comments from single or multiple review URLs, downloads commits locally, fixes verified defects via `tdd-team`, creates sequential local fix commits, and reports resolution while strictly isolating branches and never pushing to remote git repositories.

## Environment Separation
- **Local Host:** Used only to read credentials (`/Users/dc005518/.ssh/log.txt`) if review URLs require authentication.
- **Codebase Workspace:** Target repository where checkout, downloads, code edits, tests, and local commits occur.

## Inputs
- **Review URLs:** List of Gerrit, GitHub PR, or git-review URLs:
  `URL 1: https://review.example.com/c/project/+/10001 (Commit 1)`
- **Credential File (Optional):** Read-only local token credentials if review system is gated.

## Execution Workflow (Deterministic State Machine)

### Step 1: Authentication & Branch Isolation
1. Inspect workspace: `git status --porcelain`. Stash dirty files if present.
2. Record branch: `ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)`.
3. Create dedicated review branch: `git checkout -b "review-fix/session-$(date +%s)"`.
4. Guarantee local repository safety: never modify or corrupt existing branches.

### Step 2: Sequential Review Processing Loop
For each URL \(i\) and commit \(C_i\):
1. **Download Commit:** Fetch and cherry-pick review commit or apply patchset locally.
2. **Context Exploration:** Inspect symbols, callers, and dependencies with parallel tool calls.
3. **Comment Validation:** Verify whether comment is valid or a false finding. Document rationale if rejecting.
4. **Fix via tdd-team:**
   - Execute strict Red-Green-Refactor cycle.
   - Enforce 1E-class security and deterministic cleanup (`defer`, `with`, RAII, `trap ... EXIT`).
   - Format only modified lines (`gofmt`, `clang-format`); eliminate spaces/tabs on empty lines.
   - Run `ReadLints` and confirm test suite passes.
5. **Generate Local Fix Commit:**
   Stage only verified changes and create sequential local commit \(C_i'\):
   `git commit -m "review-fix: address review comments for URL $i ($COMMIT_ID)"`
6. **Record Resolution:** Append record to `aigen_doc/ai-review-fix-report.md` (URL, location, comment, fix summary, review reply).

### Step 3: Final Verification & Handover
1. Run full test suite; ensure all unit, integration, and regression tests pass green.
2. Verify zero temporary files remain (`*.bak`, `*.tmp`, `patch.sh*`, `.cursor_build.*`).
3. Compile final table in `aigen_doc/ai-review-fix-report.md`.
4. Strictly verify zero remote pushes occurred.

## Constraints & Quality Bar
- **Local Git Commits Only:** Generate local fix commits (\(C_i \to C_i'\)) for each review commit.
- **Strictly No Remote Push:** Running `git push` is unconditionally forbidden.
- **Strict Resource Lifecycle:** Guarantee deterministic cleanup (`defer`, `with`, `finally`).
- **Formatting Scope:** Format strictly modified lines; eliminate trailing whitespace on blank lines.

## Negative Constraints (Must NOT)
- [X] **Do not push commits to remote git repositories.** Running `git push` is strictly forbidden.
- [X] **Do not break or damage other local branches or commits.** Preserve all existing branches and commits.
- [X] **Do not update the gitreview comments directly via API.** Output replies in report for manual posting.
- [X] **Do not reformat unchanged code lines.** Restrict formatting exclusively to changed lines.
- [X] **Do not leave space/tab-only empty lines.** Eliminate trailing whitespace on blank lines to avoid gitreview red flags.
- [X] **Do not delete failing tests.** Fix underlying logic to satisfy test assertions.
- [X] **Do not echo credentials to chat or logs.** Redact tokens and passwords.

## Closing Message (mandatory exact wording)
> Review fixes completed across all URLs. Dedicated local commits generated. Tests green. Remote push strictly omitted for safety.
