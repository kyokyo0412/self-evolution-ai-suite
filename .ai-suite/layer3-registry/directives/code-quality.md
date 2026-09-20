# Master Code Quality & Audit Standards

1. **Maintainability**: Refuse functions longer than 50 lines or with high cyclomatic complexity. Break complex logic into smaller pure helper functions.
2. **Security First**: Sanitize all inputs against injection and data leaks.
3. **Performance Context**: Comment Big-O time and space complexity on complex loops/transformations. Prefer vectorized/efficient array operations.
4. **Defensive Programming**: Explicit null checks and optional chaining. Never swallow errors silently in try/catch blocks.
5. **Documentation**: Output audits and refactor proposals in structured Markdown with an actionable checkbox list.
6. **1E-Class Security**: Adhere strictly to 1E-class security standards in `nuclear-safety.md`.
7. **Code Formatting & Style Standards**:
   - **Language Standards**: Go code MUST align strictly to `gofmt`. C code MUST adhere to `clang-format`.
   - **Project Style Harmony**: Follow existing code style, naming, and indentation conventions.
   - **Clean Empty Lines & Gitreview Red-Flag Prevention**: Code files must NEVER contain empty lines consisting only of spaces or tabs. Strip all spaces/tabs from blank lines, keeping pure empty lines for visual readability to eliminate gitreview red flags.
   - **Selective Formatting Scope**: Only format new or modified code lines; never reformat unchanged code or untouched lines.
8. **Strict Resource Lifecycle & Leak Prevention**:
   - Deterministic resource lifecycle: release all file descriptors, sockets, database handles, and processes deterministically.
   - Enforce language patterns: `defer` in Go, context managers (`with`) or `finally` in Python, RAII in C++, and `trap ... EXIT` in Shell.
9. **Language-Specific Robustness Standards**:
   - **Python**: Enforce type annotations on function signatures. Forbid bare except clauses; catch explicit exception types. Deterministic cleanup.
   - **Shell**: Enforce defensive execution (`set -euo pipefail`), quote variable expansions (`"$var"`), and check `command -v`.
   - **Go**: Explicit `err != nil` handling with contextual error wrapping (`fmt.Errorf("...: %w", err)`), propagate context, prevent goroutine leaks.
   - **C/C++**: Enforce buffer bounds checking, `snprintf` over `sprintf`, validate system call return values, zero sensitive memory.
10. **Test-Driven Verification & Anti-Hardcoding Rigor**:
    - Back logic branches with automated tests covering boundary values and negative paths.
    - Anti-Hardcoding: Dynamically compute test assertions on corpus counts; never hardcode static integer counts.
11. **Pre-Review Zero-Defect Standards (Anti-AI-Review Invariants & Zero False-Positive Alignment)**:
    - Conduct adversarial pre-review audit to eliminate findings from external review tools (`ai-review-bot` alignment):
      a. **Boundary & Nil Safety**: Explicit nil guards, collection length checks, empty string bounds.
      b. **Deterministic Error Handling**: No swallowed errors, explicit contextual error wrapping.
      c. **Strict Resource Lifecycles**: Deterministic release (`defer`, `with`, `finally`, `trap ... EXIT`).
      d. **Concurrency Safety**: Thread-safe access, atomic operations, explicit lock order, zero unsynchronized mutations.
      e. **Security & Input Sanitization**: Shell variable quoting (`"$var"`), path traversal defense, buffer bounds checking.
      f. **Algorithmic Efficiency**: Bounded loop iterations, $O(N)$ efficiency.
      g. **Clean Whitespace & Style**: Zero space/tab-only empty lines to eliminate gitreview red flags.
      h. **Case-Insensitive Normalization**: Mandatory lowercase normalization on FQDNs, DNS names, and hostnames.
      i. **Secret Protection**: Zero logging or emitting of unmasked passwords, tokens, or credentials.
      j. **Timing Attack Prevention**: Avoid early-exit skips on cryptographic or authentication hash checks.
      k. **Class Guard Execution**: Ensure class input validation methods are invoked on untrusted data.

## Negative Constraints (Must NOT)
- [X] **Do not write monolithic functions**: Never exceed 50 lines or high cyclomatic complexity.
- [X] **Do not swallow errors silently**: Always handle, log, or propagate errors.
- [X] **Do not hardcode corpus counts**: Always compute entity counts dynamically.
- [X] **Do not leave unclosed resources**: Guarantee deterministic deallocation of handles and child processes.
- [X] **Do not leave space/tab-only empty lines**: Zero trailing whitespace on blank lines to prevent gitreview red flags.
- [X] **Do not reformat untouched code**: Limit formatting strictly to changed lines.
- [X] **Do not bypass Pre-Review Zero-Defect verification**: Conduct adversarial review audit before sign-off.
