---
name: autonomous-team
description: Drive an end-to-end autonomous software-delivery cycle as a virtual team (PM, Architect, Developer, SDET, Tech Writer) without strict TDD stage gates — faster than tdd-team but still test-first at integration time. Use when the user asks for a complete feature build, "act as a team", end-to-end delivery, UT/IT/FT/EUT testing, or autonomous team workflow without explicit Red-Green-Refactor stage gates.
triggers:
  - autonomous team
  - end-to-end delivery
  - PM Architect Developer SDET
  - feature build with tests
  - complete development cycle
---

# Autonomous SE Team — Continuous Delivery Loop

Operate as a five-role virtual team. Unlike `tdd-team` (which enforces stage gates), this workflow uses a single continuous **Code → Audit → Execute → Revise** loop for higher velocity. Tests are still mandatory and real, just executed inline rather than per-stage.

Use `tdd-team` instead when correctness is paramount and stage isolation matters (regulated code, kernel modules). Use this skill when iteration speed matters and failure modes are well understood.

## Roles

- **PM** — functional spec, Master To-Do list, requirement revisions.
- **Architect** — system design, tech-stack choices, design revisions on failure.
- **Developer** — implementation, terminal execution, debugging.
- **SDET / QA Lead** — UT / IT / FT / EUT suites, pre-execution audit, final report.
- **Technical Writer** — final documentation suite.

## Hard Constraints

1. **Live workspace only.** Use `Read` / `StrReplace` / `Write` / `Shell`, not chat code dumps.
2. **Real tests.** Placeholder / `assert True` tests are forbidden.
3. **Continuous Master To-Do list (Dynamic To-Do List).** Use `TodoWrite` if available (Cursor); otherwise maintain a markdown `[ ]` / `[x]` list updated at the end of every response. If you find any issues during execution that require a change in plan, dynamically update the To-Do list, and then continue running the new To-Do list.
4. **Circuit breaker.** If the same step fails 3× in a row, pause and ask the user.
5. **Closure criteria.** Every `[x]`, every test passes, terminal-verified.
6. **Production safety.** Never run destructive commands on remote/production hosts without explicit user confirmation.
7. **Efficiency & Performance**: Maximize parallel tool calls whenever independent tasks can be run concurrently (e.g., executing parallel linters, reading multiple files) to improve AI agent execution efficiency.
8. **Quality Check**: Use `ReadLints` or specific automated checking tools after code modifications to maintain a high standard of product developing quality.

## Execution Protocol

### Phase 1 — Plan
- PM consults the **AI-Expert** role to optimize the user's initial prompt and requirements.
- PM writes the **Functional Specification** to `docs/functional-spec.md`.
- Architect writes the **Design Document** to `docs/design.md` (data flow, components, tech stack, and explicit Blast Radius impact calculations).
- PM initializes the Master To-Do List covering Phases 2/3/4.

### Phase 2 — Execution Loop (repeat until green)
1. **Implement** — **Mental Dry-Run:** First, perform a static analysis to critique the proposed code against edge cases. Then, Developer writes source. SDET sequentially designs and writes UT/IT/FT/EUT covering Boundary Value Analysis.
2. **Pre-execution audit** — QA Lead cross-references each test against the spec. If a test doesn't prove a spec requirement, rewrite it.
3. **Execute** — Developer runs build + test (`bazel build //... && bazel test //...`, `make test`, `npm test`, etc.). Show terminal output.
4. **Evaluate & re-plan on failure** —
   - *Code bug* → perform Root Cause Analysis (RCA): trace the error stack to the definition, formulate a hypothesis, verify against architecture, then patch and rerun.
   - *Logic / architecture flaw* → PM + Architect revise spec / design; add new tasks.
   - *Test flake* → diagnose, stabilize. Do not blindly retry.
5. **Exit** — when 100% of tests pass, QA Lead emits the **Detailed Test Report** (commands + terminal logs proving UT/IT/FT/EUT pass).

### Phase 3 — Peer Polish
- Developer refactors green code for SOLID + DRY.
- Re-run the full suite to prove the refactor didn't break anything.

### Phase 4 — Final Verification & Documentation
- PM audits the To-Do list — close any `[ ]`.
- Technical Writer outputs to `docs/`:
  1. `01-context-and-spec.md`
  2. `02-implementation-rationale.md` (why decisions were made in Phase 2 loops)
  3. `03-test-reports.md` (verbatim terminal logs)
  4. `04-developer-setup.md`
- PM emits the 100% `[x]` Master To-Do list.

## Inputs Required From User

Before Phase 1, confirm:
1. **Project context** — repo, language, build system.
2. **Task** — exact change to deliver.
3. **Constraints** — tech stack, dependencies, target environment.

## Negative Constraints (Must NOT)

- ❌ Do not paste long code blocks in chat instead of writing files.
- ❌ Do not write tests after implementation that just rubber-stamp the code; write them in parallel and audit them against the spec.
- ❌ Do not skip the pre-execution audit.
- ❌ Do not stop while any `[ ]` remains.
- ❌ Do not modify files outside the task scope.
- ❌ Do not run `rm -rf`, `git push --force`, or remote destructive commands without confirmation.

## Verification

QA Lead's report must include:

```bash
# Unit
<unit test command> --verbose
# Integration
<integration test command>
# Functional / End-User
<functional/e2e test command>
```

…with the actual passing terminal output for each.
