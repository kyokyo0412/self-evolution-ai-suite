# Master Code Quality & Audit Standards

1. **Maintainability**: Refuse functions longer than 50 lines or with high cyclomatic complexity; decompose into small pure helpers.
2. **Defensive Programming & Security**: Validate boundaries, sanitize inputs, never swallow errors silently in try/catch or except blocks.
3. **1E-Class Security Standards**: Enforce bounded execution and resource lifetimes. Apply allocation-free hot paths only to a documented safety-critical profile that requires them.
4. **Strict Resource Lifecycles**: Release all file descriptors, sockets, database handles, and processes deterministically (`defer` in Go, context managers (`with`) or `finally` in Python, RAII in C++, `trap ... EXIT` in Shell).
5. **Formatting & Whitespace (Gitreview Red-Flag Prevention)**:
   - Go code must align to `gofmt`; C code to `clang-format`.
   - Zero space/tab-only empty lines: strip trailing whitespace from blank lines.
   - Selective formatting: format only new or modified lines; never reformat untouched lines.
6. **Anti-Hardcoding & Testing**:
   - Dynamically compute test assertions on corpus counts; never hardcode static integer counts.
   - Comprehensive boundary value analysis and negative path testing.
7. **Risk-Based Pre-Review Checks**:
   - Normalize case for DNS names and hostnames where comparison follows a case-insensitive protocol; preserve case-sensitive identifiers and original display values.
   - Secret protection: mask all passwords, tokens, and credentials.
   - Use the platform's constant-time comparison for secret-bearing values where timing matters; an ordinary content checksum is not automatically an authentication boundary.
   - Validate untrusted data at module boundaries using the project's actual types, schemas, and guards; do not invent a guard API.
   - Select checks from changed behavior and credible failure paths. Record commands, results, baseline issues, and verification limits; passing checks do not prove absence of defects.

## Negative Constraints (Must NOT)
- [X] **Do not write monolithic functions**: Never exceed 50 lines or high cyclomatic complexity.
- [X] **Do not swallow errors silently**: Always handle, log, or propagate errors.
- [X] **Do not hardcode corpus counts**: Always compute entity counts dynamically.
- [X] **Do not leave unclosed resources**: Guarantee deterministic deallocation of handles and child processes.
- [X] **Do not leave space/tab-only empty lines**: Zero trailing whitespace on blank lines to prevent gitreview red flags.
- [X] **Do not reformat untouched code**: Limit formatting strictly to changed lines.
- [X] **Do not bypass pre-review verification**: Conduct adversarial review before sign-off and report unresolved findings honestly.
