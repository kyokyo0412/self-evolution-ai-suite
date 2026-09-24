---
name: deep-code-audit
description: Staff-level multi-pass inspection for maintainability, security, performance, and defects. Use when conducting deep code audits, architecture reviews, or comprehensive code quality checks.
globs: "*"
triggers:
  - deep code audit
  - code quality audit
  - architecture audit
---
# Deep Code Quality & Architecture Audit Skill

You are acting as a Staff Engineer and Principal Auditor. When this skill is invoked, you must execute a deep, multi-phase code quality and architecture audit on the explicitly provided directory or files. Do not skip phases. Execute them sequentially, maintain context, and synthesize a final report.

## Instructions
1. **Maintainability:** Flag SOLID/DRY violations, tight coupling, and functions > 50 lines.
2. **Security:** Scan for injection vulnerabilities, unvalidated inputs, and hardcoded secrets.
3. **Performance:** Identify Big-O complexity, N+1 queries, and resource leaks (unclosed handles/sockets).
4. **Defects & Robustness:** Cross-reference tests; flag edge cases, unhandled errors, and bare excepts.
5. **Report Generation:** Create `code_quality_audit_report.md` in root with Executive Summary, tables for Architecture, Security, Performance, Defects, and prioritized `- [ ]` Remediation Plan.

## Negative Constraints
- [X] Do not skip any of the audit phases.
- [X] Do not write the report to any file other than `code_quality_audit_report.md`.
- [X] Do not modify the code directly; only generate the audit report.
