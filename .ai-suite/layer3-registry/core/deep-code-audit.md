---
name: deep-code-audit
description: Inspect a specified codebase for architecture, maintainability, security, performance, and defects. Use when conducting deep code audits, architecture reviews, or comprehensive code quality checks.
triggers:
  - deep code audit
  - code quality audit
  - architecture audit
---

# Deep Code and Architecture Audit

## Inputs and authority

Resolve the target paths/revision, audit question, relevant project standards, and requested output. This is a report-only workflow: preserve code, configuration, and the index. Run reproductions in disposable fixtures. If the user requests fixes, hand verified findings to `tdd-team` or another authorized delivery workflow instead of treating this audit's report-only constraint as a ban on the user's requested work.

## Instructions

1. Map target entry points, state, dependencies, tests, and trust boundaries. State the covered scope and prioritize critical behavior when the repository is large.
2. **Maintainability:** Identify coupling, unclear contracts, duplicated responsibilities, and functions exceeding applicable project bounds, with concrete maintenance impact.
3. **Security:** Trace untrusted input, credentials, authorization, and injection paths through existing protections before reporting a reproducible risk.
4. **Performance:** Trace actual algorithms, query counts, allocations, and resource lifecycles; label unmeasured performance claims as hypotheses, not verified bottlenecks.
5. **Defects and language robustness:** Exercise boundary, unhandled error, concurrency, recovery, and resource leak cases using available tests or a minimal safe reproducer. Separate pre-existing failures and missing verification.
6. **Adversarial review:** Challenge each finding's reachability, scope, assumptions, evidence, and proposed remedy. Consolidate duplicates and distinguish observations from defects.

## Output and recovery

Use the user's requested report location or response format. Otherwise write `aigen_doc/code_quality_audit_report.md`, preserving existing user content and updating an existing appropriate report when possible. Include a concise scope/architecture overview, prioritized findings with file/line and trigger/impact/evidence, a remediation checklist, actual commands/results, and verification limits. Mark an audit dimension not applicable with a reason when appropriate.

If access, revision, or required tooling is missing, complete independent inspection and report the blocker, uncovered scope, and next useful action. Do not invent results or retry an inaccessible dependency indefinitely.

## Negative Constraints (Must NOT)

- [X] Do not modify source or execute production mutations during a report-only audit.
- [X] Do not omit relevant audit dimensions silently or present speculative findings as verified defects.
- [X] Do not force an output path over the user's explicit request, overwrite unrelated reports, or certify defect-free software.
- [X] Do not commit, push, or post findings remotely without explicit authorization.
