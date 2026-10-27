# The Reflection Protocol -- Evidence-based self-improvement

**Command triggers (case-insensitive, exact-phrase):**
- `Run Reflection`
- `Reflect on the last task`
- `Improve the suite`

## ABSOLUTE PRECONDITIONS

Acknowledge `Reflection Mode engaged.` and pause non-reflection work. If no prior task
exists, ask for one. Apply this protocol once per call, within the authorized scope.
Automatic reflection after complex implementation must not expand a read-only task
into unrelated source changes or trigger recursive reflection.
If no actionable issue is supported by evidence, record a no-change outcome; do not invent an improvement to satisfy the protocol. Already-authorized source fixes do not grant permission to modify global installations.

## CORE EVOLUTION PRINCIPLES

Use semantic understanding of actual workflows.
Improve how agents process the prompt, skills, rules, and evidence.
Make correct workflows easy by the end user.
Measure improvements with executable checks; do not infer quality from prose volume.

## Step 1: Six-category evidence review

Analyze Trigger Accuracy, Instruction Completeness, Safety Guard Gaps,
Tool-use Efficiency, Output Quality, and Tier Accuracy. For each observed issue, record the
evidence and severity (Critical, High, Medium, Low). Select at most one
highest-severity actionable target supported by evidence; Critical and High safety failures take precedence.
One improvement per reflection call; no speculative multi-issue rewrite.

## Step 2: Generality Gate

State the gate result before editing and justify the selected tier:
- All agents and SWE task process/procedure: `.ai-suite/layer3-registry/core/`.
- Agent-specific behavior: `.ai-suite/layer1-abstraction/agents/<agent-name>/skills/`.
- Domain-specific behavior: `.ai-suite/layer3-registry/domains/<domain-name>/skills/`.

Core must not contain domain names, agent-specific paths or tool requirements. Keep safety
boundaries and existing capabilities intact.
In a source checkout, stage the improvement in the canonical tier above. In an installed context, locate the active agent's selected skill/configuration and ownership before editing; do not assume a source tree or silently change another agent's global files. Report source collection or explicit installation as a separate operation.

## Step 3: Make one scoped improvement

Inspect the relevant skill and callers. Edit through native file tools and use
available tooling rather than inventing tool names. Preserve existing user edits.
For source changes run `bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh`. In an installed context use the verified installed launcher and `enable --verify`, or the located companion validator; report unavailable checks rather than inventing a source checkout.
Do not modify unrelated skills or production resources.

## Step 4: Acceptance testing

Add or update a companion test in `tests/` or validation. Demonstrate the observed
failure before the correction where executable; then verify the correction.
For test-harness changes, inject a failing child and verify the gate fails.
Record actual exit statuses, skips, and remaining limitations. Do not suppress
failures or replace behavior checks with keyword-only checks.

## Step 5: Evolution report and handover

Write `.ai-suite/layer4-evolutionary/reflection/evolutions/REFLECTION-<ISO-timestamp>.md`
alongside other evolution reports with these sections:
Task Summary, Improvement Target, Root Cause, Change Description,
Generality Gate Result, Delta Summary, and executable verification evidence.
Use `ai-suite evolve collect --local` to collect explicitly selected installed
evolutions; source reports already reside in the repository for manual review.

Closing summary:
- File changed:
- Nature of the change:
- Why it improves:
- Friction it would have prevented:
- Tier:
- Evolution report:
- Test and actual result:
- Review command: `git diff --check`, `git diff`, and `git status --porcelain`.

## Negative Constraints & NON-NEGOTIABLES

- [X] Do NOT auto-commit or push. Leave changes for manual review.
- [X] Do not omit acceptance evidence or the evolution report for an applied improvement; a no-change outcome must explain its evidence and limits.
- [X] Do not reflect recursively or perform drive-by refactors.
- [X] Do not claim defect-free certification or expose hidden internal reasoning.
- [X] Do not weaken safety policies or overwrite unowned resources.

## DIAGNOSTIC HEURISTICS

An avoidable question suggests incomplete instructions. A wrongly selected skill
suggests inaccurate invocation conditions. Unsafe execution suggests a guard gap.
Repeated scans suggest tool inefficiency; verbosity suggests output-quality issues.
Agent-specific behavior in a universal skill suggests wrong tier placement.
