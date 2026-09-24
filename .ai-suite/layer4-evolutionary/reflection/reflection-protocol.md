# The Reflection Protocol -- Deep Self-Improvement Loop for `.ai-suite/`

**Command triggers (case-insensitive, exact-phrase):**
- `Run Reflection`
- `Reflect on the last task`
- `Improve the suite`

Engages **Reflection Mode** for exactly one turn across any agent environment.

## ABSOLUTE PRECONDITIONS
1. Acknowledge in chat: `Reflection Mode engaged.`
2. Refuse if no prior task exists: *"No prior task to reflect on -- please describe what you would like me to evaluate."*
3. Pause all non-reflection work.

## CORE EVOLUTION PRINCIPLES
- **Semantic Understanding**: Base evolution on deep semantic analysis of workflows.
- **Agent Effectiveness**: Measurably improve agent reasoning and execution fidelity.

## STRICT PROTOCOL
1. **6-Category Analysis:** Analyze Trigger Accuracy, Instruction Completeness, Safety Guard Gaps, Tool Efficiency, Output Quality, Tier Accuracy.
2. **Generality Gate:**
   - All agents / SWE process -> `layer3-registry/core/`
   - Agent-specific -> `agents/<agent-name>/skills/`
   - Domain-specific -> `domains/<domain-name>/skills/`
3. **Edit Artifact:** Use native file tools (`Read`, `StrReplace`, `Write`). Run `validate-suite.sh`.
4. **Acceptance Testing:** Update companion tests in `validation/` or `tests/`. Verify test passes.
5. **Evolution Report:** Emit `.ai-suite/layer4-evolutionary/reflection/evolutions/REFLECTION-<ISO-timestamp>.md`.
6. **Closing Summary:** Report file changed, test added, tier, why it improves, and git review command (do NOT auto-commit).

## NON-NEGOTIABLES & Negative Constraints (Must NOT)
- [X] Do not perform multi-issue improvements; resolve exactly one improvement target per reflection call.
- [X] Do not perform drive-by refactors outside the improvement target.
- [X] Do not omit the evolution report.
- [X] Do not allow recursive reflection within the same turn.
- [X] Do not commit or push autonomously (NOT auto-commit).
- [X] Core must not contain agent tokens or Cursor-specific references.

## DIAGNOSTIC HEURISTICS
Use during Step 1:
- Clarifying question asked that could be inferred -> Instruction Completeness.
- Wrong skill fired -> Trigger Accuracy (tighten description with 'Use when' and triggers).
- Destructive command run -> Safety Guard Gaps.
- Verbose/fluffy output -> Output Quality (add density constraints).
- Agent-specific logic in core -> Tier Accuracy (move to `agents/<name>/`; keep core generic).
