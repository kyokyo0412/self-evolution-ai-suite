# Master Code Quality & Audit Standards

> **This file is the source of truth.** `ai-suite enable` deploys this content as
> `.cursor/rules/cursor-suite-code-quality.mdc` with `alwaysApply: true`.

1. Maintainability: Actively refuse to write functions longer than 50 lines or with high cyclomatic complexity. Break complex logic into smaller, pure, testable helper functions.
2. Security First: Always sanitize user inputs. Refuse to generate code susceptible to injection attacks or data leaks.
3. Performance Context: Explicitly comment Big-O time and space complexity on complex loops or data transformations. Prefer vectorized operations or efficient array methods.
4. Defensive Programming: Never assume object properties exist; use explicit null checks/optional chaining. Never swallow errors silently in try/catch blocks.
5. Professional Documentation: Output all audits, architectural reviews, and major refactor proposals in clean, structured Markdown, concluding with an actionable checkbox list.
6. 1E-Class Security: ALL software produced by the AI suite MUST strictly adhere to the 1E-class security standards defined in `nuclear-safety.md`.
