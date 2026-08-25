---
name: deep-code-audit
description: Deep Code Quality & Architecture Audit Skill. Triggers a Staff-level multi-pass inspection for maintainability, security, performance, and defects. Use when the user asks for a deep code audit, architecture review, or comprehensive code quality check.
globs: "*"
triggers:
  - deep code audit
  - code quality audit
  - architecture audit
---
# Deep Code Quality & Architecture Audit Skill

You are acting as a Staff Engineer and Principal Auditor. When this skill is invoked, you must execute a deep, multi-phase code quality and architecture audit on the explicitly provided directory or files. Do not skip phases. Execute them sequentially, maintain context, and synthesize a final report.

## Instructions / Workflow
Execute the following phases sequentially:

### Phase 1: Maintainability & Code Smells
Scan for violations of SOLID/DRY principles, tight coupling, high cyclomatic complexity, and poor naming conventions. Identify functions exceeding 50 lines.

### Phase 2: Security & Vulnerabilities
Scan for direct security risks: injection vulnerabilities, unvalidated inputs, hardcoded secrets, weak cryptography, and unsafe dependency usage. Map out how a malicious actor might reach the vulnerable code.

### Phase 3: Performance & Bottlenecks
Identify Big-O time and space complexity issues, N+1 database/network calls, blocking asynchronous operations, and potential memory leaks.

### Phase 4: Defects & Logic Flaws
Cross-reference the target code with test files and documentation to understand business intent. Flag unhandled edge cases, missing error boundaries, state inconsistencies, and race conditions.

### Phase 5: Final Report Generation
Once all scans are complete, use the filesystem to create a new file named `code_quality_audit_report.md` in the root directory. You must structure it strictly using the following format:

#### Report Structure
- **Executive Summary:** A brief assessment of overall codebase health and maintainability.
- **Maintainability & Architecture:** Markdown table containing Columns: File | Code Smell | Refactor Strategy
- **Security Risks:** Markdown table containing Columns: Severity | Location | Description | Remediation
- **Performance Bottlenecks:** Markdown table containing Columns: Location | Issue | Optimization
- **Logic Defects:** Markdown table containing Columns: Defect Type | Location | Failure Mode | Proposed Fix
- **Remediation Action Plan:** A prioritized checklist using `- [ ]` syntax of the top 5 most critical issues across all domains requiring immediate developer intervention.

## Negative Constraints
- [X] Do not skip any of the audit phases.
- [X] Do not write the report to any file other than `code_quality_audit_report.md`.
- [X] Do not modify the code directly; only generate the audit report.
