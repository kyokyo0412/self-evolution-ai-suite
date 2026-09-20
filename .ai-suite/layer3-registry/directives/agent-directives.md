# Agent General Directives

General rules the AI agent MUST adhere to across all tasks and interactions:

## 1. Version Control Operations
- **Leave `git commit` to the user**: Do not perform `git commit` directly. Prepare changes, optionally provide git commit command, and leave actual execution of `git commit` to the user.

## 2. Communication and Reporting
- **Provide a summary**: Upon completing any task, output a structured summary covering:
  - **What**: Accomplishments and completed items.
  - **Why**: Design choices and technical rationale.
  - **How**: Implementation steps and specifics.
  - **Key Points**: Concise list of highlights and deliverables.
- **Summary Order**: When skills specify their own normal report (e.g., `tdd-team` report), the summary report MUST follow after the normal report. Keep What, Why, How, Key Points distinctly visible.

## 3. Multiple Skills Execution
- **Multiple skills execution**: You can combine multiple skills. Preserve behavior: do not alter skills or skip steps. Execute core task skill first, then output summary report, then follow-ups.

## 4. Verification
- **Verification required**: Every task must be backed by actual verification. Tasks cannot be considered complete without running tests, validating scripts, or confirming functionality.

## 5. Deep Comprehension
- **Requirement Analysis**: The agent MUST thoroughly analyze prompts, extract intent, and refine prior to execution. Do not implement without deep comprehension of user intent.

## 6. Autonomous Resilience
- **Do not stall or prompt the user when encountering an obstacle**: Try alternative strategies, fallbacks, and diagnostic paths autonomously to resolve blocks.

## 7. Continuous Self-Evolution
- **Self-Evolution**: The agent continuously learns, adapt and refine its prompt/skill suite based on task outcomes and operational feedback.

## 8. Workspace Cleanup
- **Strict Cleanup Verification**: Verify no temporary files (`*.bak`, `*.tmp`, `patch.sh*`, `.cursor_build.*`) remain via terminal check.
- **AI agent file list inspection**: Check file list (`git status --porcelain` or directory inspection) to audit all newly created files and remove temporary/unused artifacts.
- **Active Task Cleanup Before AskQuestion**: If the active task should clean up unused and temporary files, let the active task remove them first. Then process the `AskQuestion` tool. Never leave workspace polluted.

## 9. Efficiency & Performance
- **Parallel tool calls**: Maximize parallel tool calls whenever independent tasks can run concurrently.

## 10. Quality Check & Adversarial AI-Review
- **ReadLints**: Use `ReadLints` or linters after code modifications.
- **Principal Coding Engineer Adversarial AI-Review**: Conduct an adversarial pre-review audit to proactively eliminate boundary flaws, resource leaks, and gitreview warnings before completion.

## 11. Continuous Task Tracking
- **Dynamic To-Do list**: Track multi-step tasks dynamically with TodoWrite or markdown; update status in real-time.

## 12. Code Formatting & Style Standards
- **Language Standards**: Go code MUST align to `gofmt`; C code MUST adhere to `clang-format`. Follow existing project naming and indentation conventions.
- **No Space/Tab Empty Lines & Gitreview Red-Flag Prevention**: Code files must NEVER contain empty lines consisting only of spaces/tabs. Strip trailing whitespace from blank lines, preserving clean empty lines for visual readability. This eliminates gitreview red flags.
- **Formatting Scope**: Only format new or modified code lines; never reformat untouched code.

## 13. Deterministic Resource & Subprocess Management
- **Deterministic Cleanup**: All handles, sockets, and buffers require explicit cleanup (`defer`, `with`/`finally`, `RAII`, `trap ... EXIT`). Terminate spawned subprocesses; never leave orphaned child processes.

## 14. Dynamic Test Assertions & Anti-Hardcoding Rigor
- Assertions on counts that grow with codebase MUST be dynamically computed at runtime. Never hardcode corpus size or static integer counts.

## 15. Continuous Interactive Workflow Persistence (Cursor Agent)
- **Zero-Drop Follow-Up Loop**: When interactive workflow is active, every subsequent prompt submitted via the 'Other' option is executed as a full active task (Step 1). Upon completion, the agent MUST perform workspace cleanup, output the execution summary in chat and execute `echo 'Interactive workflow summary rendered'` (Step 2), and call `AskQuestion` in the immediate next response (Step 3).
- **No Early Turn Exit**: The AI agent MUST NOT conclude the turn or stop without calling `AskQuestion` after completing a follow-up task.

## Negative Constraints (Must NOT)
- [X] **Do not run `git commit`**: The AI agent MUST NEVER run git commit autonomously.
- [X] **Do not leave temporary files**: Actively verify and clean up `.bak`, `.tmp`, `.pid`, and `.log` execution artifacts before finishing.
- [X] **Do not call AskQuestion before cleanup**: Active task must remove all temporary/unused files before calling AskQuestion.
- [X] **Do not reformat unchanged code**: Selective formatting applies strictly to new or modified lines.
- [X] **Do not leave space/tab-only empty lines**: Ensure all empty lines have zero trailing whitespace to avoid gitreview red flags.
- [X] **Do not hardcode corpus counts**: Dynamic baseline calculations mandatory for entity counts.
- [X] **Do not leak resources or subprocesses**: Guarantee deterministic deallocation of handles and processes.
- [X] **Do not skip Principal Coding Engineer Pre-Review**: Always execute adversarial review before delivery.
- [X] **Do not terminate turn without AskQuestion in active interactive workflow**: Always invoke Step 2 summary + echo and Step 3 AskQuestion for every task iteration.
