---
name: autonomous-team
description: Deliver a scoped feature through planning, implementation, review, and executable verification. Use when requesting autonomous team workflow, full feature delivery, or end-to-end integration testing.
triggers:
  - autonomous team
  - end-to-end delivery
  - PM Architect Developer SDET
  - feature build with tests
  - complete development cycle
---

# Autonomous Software Team

## Inputs and authority

Establish the requested outcome, repository, acceptance cases, compatibility constraints, and available environments. Infer routine choices from project evidence; ask early for missing essential information or required authorization while continuing independent work. Work within user scope and host policies. Use supported tools; role names describe responsibilities, not proof that separate agents ran.

## Team responsibilities

- **PM:** Requirements, scope, acceptance evidence, and dynamic Master To-Do list.
- **Architect:** Interfaces, state integrity, failure recovery, and affected resource bounds.
- **Developer:** Minimal maintainable implementation and deterministic cleanup.
- **SDET / QA Lead:** Meaningful assertions, boundaries, failure paths, regression checks, and recorded test results.
- **Technical Writer:** Update relevant existing documentation and explain operational changes.

Instantiate UI, mobile, regulatory, or other specialists only for affected concerns. Use `tdd-team` when test-first or BDD stages are requested; preserve its RED/GREEN and review gates rather than running conflicting parallel workflows.

## Execution Protocol

1. **Plan:** Inspect code, tests, workspace status, and applicable rules. Record requirements, risks, intended edits, and acceptance commands in the dynamic Master To-Do list. Capture baseline failures separately.
2. **Implement and verify:** Choose the smallest behavior increment. SDET audits tests against the requirement before execution; use existing regressions or add meaningful failing cases for behavior defects. Developer implements and runs affected checks. Use parallel tool calls for independent reads/checks; keep dependent edits sequential.
3. **Review and refactor:** Challenge assumptions and verified failure paths before delivery. Apply SOLID/DRY where it improves the change. Use deterministic resource cleanup (`defer`, context managers, `finally`, `trap ... EXIT`). Apply `gofmt` for Go, `clang-format` for C, and project language standards to modified code only; never reformat unchanged lines. Clean whitespace-only blank lines to avoid gitreview red flags. Run ReadLints when available or the project's equivalent linter checks.
4. **Closure:** Run relevant integration/end-to-end checks only in authorized environments. Update documentation proportionate to changed behavior. Reconcile every To-Do item with evidence; report passed, failed, blocked, and not-applicable checks separately. Failed or blocked work remains incomplete and unchecked; never manufacture a fully checked list.

## Recovery and output

Update the To-Do list as new issues, evidence, or scope changes arise; continue outstanding work within authorization and keep blocked items visible.

After three consecutive failures, reassess the cause and try a bounded alternative within the task's time and attempt budget. If an essential external blocker remains, preserve the current patch, completed work, failing evidence, and next action; request only the missing input or authorization. Do not loop indefinitely or bypass a required gate.

Report what changed, why, how it was verified, remaining risks, and focused workspace status. A failed required check prevents a completion claim. Preserve user changes and leave commits and pushes to the user.

## Negative Constraints (Must NOT)

- [X] Do not stop useful authorized work merely to request approval between routine phases.
- [X] Do not hide failures, replace tests with placeholders, or delete meaningful failing tests to obtain green.
- [X] Do not modify unrelated files, reformat unchanged code, expose secrets, or leak subprocesses/resources.
- [X] Do not run destructive remote operations or bypass required authorization.
- [X] Do not commit or push autonomously.
