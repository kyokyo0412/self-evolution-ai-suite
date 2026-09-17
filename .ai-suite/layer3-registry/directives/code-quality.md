# Master Code Quality & Audit Standards

> **This file is the source of truth.** `ai-suite enable` deploys this content as
> `.cursor/rules/cursor-suite-code-quality.mdc` with `alwaysApply: true`.

1. Maintainability: Actively refuse to write functions longer than 50 lines or with high cyclomatic complexity. Break complex logic into smaller, pure, testable helper functions.
2. Security First: Always sanitize user inputs. Refuse to generate code susceptible to injection attacks or data leaks.
3. Performance Context: Explicitly comment Big-O time and space complexity on complex loops or data transformations. Prefer vectorized operations or efficient array methods.
4. Defensive Programming: Never assume object properties exist; use explicit null checks/optional chaining. Never swallow errors silently in try/catch blocks.
5. Professional Documentation: Output all audits, architectural reviews, and major refactor proposals in clean, structured Markdown, concluding with an actionable checkbox list.
6. 1E-Class Security: ALL software produced by the AI suite MUST strictly adhere to the 1E-class security standards defined in `nuclear-safety.md`.
7. Code Formatting & Style Standards:
   - **Language Standards**: When generating or modifying Go code, format MUST align strictly to `gofmt` standards. When generating or modifying C code, format MUST follow `clang-format` conventions.
   - **Project Style Harmony**: Follow the existing code style, naming conventions, and indentation patterns of the target project when generating or modifying code.
   - **Clean Empty Lines & Gitreview Red-Flag Prevention**: Code files must NEVER contain trivial empty lines consisting only of spaces or tabs. When code lines contain spaces or tabs in front of the line and no other real code in that line, the AI suite MUST remove all spaces and tabs for that line, keeping only a pure empty line without whitespace for visual readability. This eliminates red flags and trailing whitespace warnings in gitreview, Gerrit, and diff tools.
   - **Selective Formatting Scope**: Only apply formatting to newly added or modified code lines. Do NOT reformat unchanged code or untouched lines unless explicitly requested by the user.
8. Strict Resource Lifecycle & Leak Prevention:
   - All file descriptors, network connections, database handles, child processes, and allocated buffers MUST have explicit, deterministic cleanup lifecycles.
   - Use language-native deterministic cleanup patterns: `defer` in Go, context managers (`with`) or `finally` blocks in Python, RAII in C++, and deterministic `trap ... EXIT` in Shell scripts.
   - Never leak open handles, orphaned child processes, or lingering temporary files.
9. Language-Specific Robustness Standards:
   - **Python**: Enforce type annotations on all function signatures. Forbid bare except clauses (e.g., bare `except:`); always catch explicit, structured exception types. Ensure clean, deterministic cleanup of resources.
   - **Shell**: Enforce defensive execution (`set -euo pipefail` where applicable), strictly quote variable expansions (`"$var"`), verify command existence (`command -v`), and avoid unquoted globbing.
   - **Go**: Require explicit `err != nil` handling with contextual error wrapping (`fmt.Errorf("...: %w", err)`), propagate context (`ctx context.Context`), and prevent goroutine leaks.
   - **C/C++**: Enforce rigorous buffer bounds checking, zero out sensitive memory buffers, validate all return values of system calls, and avoid unbounded string operations (`snprintf` over `sprintf`).
10. Test-Driven Verification & Anti-Hardcoding Rigor:
   - Every logic branch and failure path MUST be backed by executable automated tests covering boundary values (BVA) and negative paths.
   - Anti-Hardcoding Invariant: Assertions on counts that grow with the codebase MUST be computed dynamically at runtime, never hardcoded as static integer literals.
11. Pre-Review Zero-Defect Standards (Anti-AI-Review Invariants):
   - Before presenting code for completion or human review, the AI agent MUST simulate external AI review tools (SonarQube, CodeQL, Bugbot, Gerrit AI Reviewers) and actively eliminate any potential review findings.
   - Mandatory Pre-Review Audit checklist:
     a. **Boundary & Nil Safety**: Explicit nil/null guards, collection length validation, off-by-one verification.
     b. **Deterministic Error Handling**: No swallowed errors, explicit propagation, contextual wrapping.
     c. **Strict Resource Lifecycles**: Guarantee deterministic resource release (`defer`, `with`, `finally`, `trap ... EXIT`).
     d. **Concurrency Safety**: Thread-safe structures, explicit mutex locking orders, zero unsynchronized mutations.
     e. **Security & Input Sanitization**: Mandatory shell variable quoting (`"$var"`), path traversal guards, injection defense.
     f. **Algorithmic Efficiency**: Bounded loop iterations, $O(N)$ vs $O(N^2)$ verification.
     g. **Clean Whitespace & Style**: Absolute zero space/tab-only empty lines to eliminate gitreview red flags.
   - Any identified defect must be patched immediately via the autonomous remediation loop before task sign-off.

## Negative Constraints (Must NOT)
- [X] **Do not write monolithic functions**: Never write functions longer than 50 lines or with high cyclomatic complexity.
- [X] **Do not swallow errors silently**: Never catch exceptions or errors without handling, logging, or propagating.
- [X] **Do not hardcode corpus counts**: Never write static integer counts in test assertions for dynamic codebase entities.
- [X] **Do not leave unclosed resources**: Never exit without deterministic cleanup of file descriptors, sockets, processes, or temporary allocations.
- [X] **Do not leave space/tab-only empty lines**: Code files must never contain trivial empty lines consisting only of spaces or tabs.
- [X] **Do not reformat untouched code**: Selective formatting must only apply to new or modified lines.
- [X] **Do not bypass Pre-Review Zero-Defect verification**: Never mark a task complete without executing the adversarial review audit to eliminate defects that external AI review tools would flag.
