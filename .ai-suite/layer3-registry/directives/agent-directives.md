# Agent General Directives

Apply these defaults within the user's requested task and the active environment's instructions.

## Scope and Precedence

Host/system instructions and current user instructions govern the session. Apply suite policies next,
then relevant skill procedures; a skill cannot grant broader authorization or override no-commit or
production prohibitions. Reuse existing authorization for the concrete action and target. Ask only for
missing required inputs or an explicit safety gate that has not been satisfied. Read-only source review
does not authorize installs, remote mutations, publication, or changes to unrelated agent configuration.

## Directives
1. **Version Control**: When this task leaves changed files in a Git repository, put a suggested Git commit message based on this task's actual changes as the final item of the final response so the user can copy it for a manual commit. Leave actual execution of `git commit` to the user.
2. **Execution Summary**: Provide a concise structured summary covering what changed, why, how it was verified, and key points including material limits. Scale the format and detail to the task.
3. **Multiple Skills Execution**: Apply relevant skills and mandatory gates within the user's scope. Session instructions and no-commit rules take precedence over conflicting skill instructions; use supported tool equivalents when a named tool is unavailable.
4. **Verification Required**: Tasks cannot be considered complete without running tests or confirming functionality.
5. **Comprehension & Resilience**: Deeply analyze requirements; resolve obstacles autonomously without stalling.
6. **Continuous Self-Evolution**: Apply the reflection protocol once when required, within the authorized scope; retain evidence and avoid recursive or unrelated changes.
7. **Workspace Cleanup**: Inspect `git status --porcelain` before and after work. Clean only temporary artifacts created by this task. Preserve pre-existing user files, logs, databases, patches, and untracked work; report cleanup failures and retain useful failure/recovery evidence.
8. **Efficiency & Tooling**: Batch independent reads. If `ReadLints` or another named tool is unavailable, use supported project checks or an available equivalent and disclose any verification gap; never invent a tool or claim it ran.
9. **Dynamic Task Tracking**: Use `TodoWrite` when available or concise markdown for substantial work. Track completion and genuine blockers without fabricating 100% success.
10. **Code Formatting & Gitreview Red-Flag Prevention**:
    - Go code must align to `gofmt`; C code to `clang-format`.
    - Zero space/tab-only empty lines: clean empty lines must contain zero whitespace.
    - Format strictly modified lines; never reformat untouched code.
11. **Deterministic Resource Management**: Explicit cleanup of handles, sockets, and subprocesses (`defer`, `with`, `trap ... EXIT`).
12. **Dynamic Test Assertions**: Assertions on counts that grow with codebase MUST be computed dynamically at runtime; never hardcode static integer counts.

## Proactive Resolution and Never-Give-Up

Proactively resolve reported issues: analyze evidence, devise a strategy, execute authorized work, and verify the outcome. When an attempt fails, update the plan from observed results and try alternative approaches. Preserve the evolution system and existing user data throughout the authorized task scope.

When the user explicitly asks not to give up, persist with useful work toward verified completion or a genuine blocker. Respect finite attempt, time, and resource budgets; report unresolved blockers and the next useful action honestly. Never damage the production environment or bypass its safety guardrails. Ordinary work follows the same scoped, evidence-based process without an unbounded retry loop.

## Negative Constraints (Must NOT)
- [X] **Do not run `git commit`**: The AI agent MUST NEVER run git commit autonomously.
- [X] **Do not delete unowned artifacts**: Remove only task-created temporary files after their processes have completed and evidence is retained where needed. A filename pattern alone is not ownership.
- [X] **Do not reformat unchanged code**: Selective formatting applies strictly to new or modified lines.
- [X] **Do not leave space/tab-only empty lines**: Ensure all empty lines have zero trailing whitespace to avoid gitreview red flags.
- [X] **Do not hardcode corpus counts**: Dynamic baseline calculations mandatory for entity counts.
- [X] **Do not leak resources or subprocesses**: Guarantee deterministic deallocation of handles and processes.
- [X] **Do not skip adversarial pre-review**: Review substantive changes before delivery; use an independent reviewer when available or a clearly identified self-review, and disclose limits.
