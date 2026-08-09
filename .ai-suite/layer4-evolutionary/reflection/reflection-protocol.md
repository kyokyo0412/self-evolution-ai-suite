# The Reflection Protocol — Deep Self-Improvement Loop for `.ai-suite/`

**Command triggers (case-insensitive, exact-phrase):**
- `Run Reflection`
- `Reflect on the last task`
- `Improve the suite`
- `运行反思`

These triggers, or any explicit instruction referencing this file, place you (the AI) into
**Reflection Mode** for exactly one turn.

> **Agent-agnostic:** This protocol works identically in Cursor, Claude Code, OpenCode,
> or any other AI agent. It contains no agent-specific APIs or paths.

---

## ABSOLUTE PRECONDITIONS

Before any other action in Reflection Mode you MUST:

1. **Acknowledge the mode switch** in chat with the single line: `Reflection Mode engaged.`
2. **Refuse the trigger** if no concrete prior task exists in the conversation. Reply:
   *"No prior task to reflect on — please describe what you would like me to evaluate."*
3. **Pause all non-reflection work.** Do not continue the original task.

## CORE EVOLUTION PRINCIPLES

Every evolution MUST adhere to these semantic principles:
- **Semantic Understanding:** Base the evolution on deep semantic understanding of the prompt, skills, and rules. Do not rely purely on syntactic or file-level matching.
- **Agent Effectiveness:** The evolution MUST demonstrably improve how the AI suite Agent understands and process the prompt, skills, rules, or other artifacts.
- **End-User Usability:** The evolution MUST make the AI suite easy to be used easy by the end user (e.g., simplifying triggers, reducing cognitive load, providing clear instructions).

---

## STRICT PROTOCOL (execute in this exact order)

### Step 1 — Deep 6-Category Analysis & Contextual Memory

Analyze the previous task across **all six categories** and tag each finding with a severity:

> **Severity scale:** `Critical` (broke functionality) | `High` (caused multi-turn recovery) |
> `Medium` (added unnecessary steps) | `Low` (minor friction)

| Category | What to examine | Typical fixes |
|---|---|---|
| **Trigger Accuracy** | Was the right skill found and activated? Was the wrong skill used? Did a trigger mismatch cause a wrong path? | Tighten `description:` or add a `triggers:` entry |
| **Instruction Completeness** | Were all steps present and unambiguous in the skill? Were there instruction gaps, missing context, missing examples? Did the AI have to ask the user for information the skill should have provided? | Add steps, assumptions, or richer examples to the skill |
| **Safety Guard Gaps** | Was any destructive or irreversible action taken without a preflight? Was a production host touched without confirmation? Was a commit/push done without user review? | Strengthen Safety Preflight block or reference `production-safety.md` |
| **Tool-Use Efficiency** | Were there excessive re-reads, redundant terminal calls, wasted turns, unnecessary clarification questions? Did the AI loop on the same failure? | Add circuit-breakers ("pivot after 3 identical failures"), more context up-front |
| **Output Quality** | Was the result clear and actionable? Did the AI leave the user with copy-paste commands? Was the output verbose or fluffy without substance? | Add density/format constraints; mandate copy-paste output |
| **Tier Accuracy** | Did the AI put a general skill in an agent-specific directory, or vice versa? Did the user have to manually point out the correct directory (e.g., `core` vs `agents`)? | Add strict tier-placement rules to the skill creation/enhancement instructions |

Produce a **short candid table** of findings. Example:

```
| Category              | Finding                                        | Severity |
|---|---|---|
| Trigger Accuracy      | Wrong skill fired; tdd-team not triggered       | High     |
| Instruction Gaps      | Missing "always run shellcheck" constraint       | Medium   |
| Safety Guard Gaps     | None                                            | —        |
| Tool-Use Efficiency   | Re-read same file 4 times                       | Medium   |
| Output Quality        | Final summary lacked copy-paste git commands    | High     |
| Tier Accuracy         | Placed general skill in agent-specific dir      | High     |
```

**Selection rule:** Only `Critical` or `High` findings drive the improvement target.
If multiple Critical/High issues exist, pick the **highest-severity** one for this call.
State: *"Selected issue: `<category>` / `<severity>` — rationale: <one sentence>."*

---

### Step 2 — Generality Gate + Identify Improvement Target

Before choosing which file to edit, run the **3-Question Generality Gate**:

```
        Q1. Applies to all agents (general skills/prompts)?
            → YES: target lives in  .ai-suite/core/

        Q2. Is it a task process procedure (TDD, SWE, quality)?
            → YES: target lives in  .ai-suite/layer3-registry/core/

        Q3. Is this improvement specific to ONE AI agent
            (e.g., Cursor IDE, Claude Code)?
            → YES: target lives in  .ai-suite/layer1-abstraction/agents/<agent-name>/

        Q4. Is this improvement specific to ONE software domain
            (e.g., Kubernetes, vendor-specific)?
            → YES: target lives in  .ai-suite/layer3-registry/domains/<domain-name>/
```

**Gate result MUST be stated before any edit begins:**
> *"Gate result: Q1=YES / Q2=NO / Q3=NO → target is in `.ai-suite/core/`."*

**Tier invariants to enforce:**
- A file in `core/` must NOT contain agent-specific APIs, token names, or host references
  (no Cursor-only APIs, no Claude-only syntax).
- A file in `core/` must NOT contain domain system names (e.g., Kubernetes, AWS, etc.).
- A file in `agents/cursor/` contains only Cursor IDE specifics.
- A file in `domains/<domain>/` contains only domain specifics.

**Then choose exactly ONE of:**

- **(a) Edit an existing file** — name the exact tier-qualified path, e.g.,
  `.ai-suite/layer3-registry/core/tdd-team.md` or `.ai-suite/layer1-abstraction/agents/cursor/skills/ai-suite-architect.md`
- **(b) Create a new file** — state the tier-qualified path and justify why no existing file covers this
- **(c) Edit `.ai-suite/layer4-evolutionary/validation/` infrastructure** — only if friction was caused by the meta layer itself
  (validate-suite.sh, run-acceptance-tests.sh, etc.); NOT enable_suite.sh / disable_suite.sh / evolve_suite.sh

State: *"Improvement target: `<path>` (tier: `<core|agents/X|domains/X>`) — rationale: <one sentence>."*

If a **new file** is created, the closing summary MUST explicitly state the tier chosen and justify it
(e.g., "New file placed in `agents/cursor/` because it uses Cursor-specific APIs and IDE constructs.").

---

### Step 3 — Edit the Skill / Template / Meta File

- Use file-edit tools (`Read` first, then `StrReplace` or `Write`).
  Do **NOT** pipe `sed` or `cat` into files.
- Preserve YAML `---` frontmatter and the existing `name:` / `description:` / `triggers:` fields
  unless those are the bug.
- Skill descriptions MUST keep the `Use when …` phrase so the dist-format validator keeps passing.
- Make changes **modular**, **strict**, and **highly actionable** — every new instruction must be testable.
- Ensure your changes adhere to the **CORE EVOLUTION PRINCIPLES** (Semantic Understanding, Agent Effectiveness, End-User Usability).
- **AI-Expert Review**: Before finalizing the edit, assume the **AI-Expert** role to review the enhancement and confirm it improves the AI agent's working capabilities.
- Keep the file scoped to one responsibility.
  If two improvements would crowd the file, split into a sibling file and address the second in
  the next Reflection call.
- After editing, run: `bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh`
  (no arguments — scans all three tiers: core/, agents/, domains/).

---

### Step 4 — Autonomous Acceptance Testing (Self-Validation)

Before writing the evolution report, you MUST prove the change works.

1. Write a companion test script in `.ai-suite/layer4-evolutionary/validation/` (e.g., `test-skill-name.sh` or update an existing `.feature` file).
2. Run the test locally and verify it passes.
3. If the test fails, fix your change and re-run. Do NOT proceed to Step 5 until the test passes.

---

### Step 5 — Write the Evolution Report

After completing the edit and the test, write a structured Markdown report to:

```
.ai-suite/layer4-evolutionary/reflection/evolutions/REFLECTION-<ISO-timestamp>.md
```

Use `date -u +%Y%m%dT%H%M%SZ` for the timestamp. Create the `evolutions/` directory if it does not exist.

**Required sections:**

```markdown
## Task Summary
<What the human was trying to accomplish in the previous task — 2-3 sentences>

## Improvement Target
- **File:** `<tier-qualified relative path>`
- **Tier:** core / agents/<name> / domains/<name>

## Root Cause
- **Category:** <which of the 6 categories>
- **Severity:** Critical / High / Medium / Low
- **Description:** <one paragraph explaining the root cause>

## Change Description
<What was edited or created, and why — be specific; include the key text delta>

## Generality Gate Result
- Q1 (all agents): YES/NO
- Q2 (agent-specific): YES/NO
- Q3 (domain-specific): YES/NO
- **Tier chosen:** core / agents/<name> / domains/<name>
- **Justification:** <one sentence>

## Delta Summary
<Brief summary of key additions/removals — can be bullet points or inline diff excerpts>
```

**Why this report exists:**
The `evolutions/` directory is shared with `evolve_suite.sh collect`.
When a remote SSH instance runs Reflection, the evolution report is produced there.
On the next `collect` run, the report is synced back to the local git repository alongside
the edited skill/template files, giving you a machine-readable history of every improvement.

---

### Step 6 — Emit the Closing Summary

End your turn with EXACTLY this block (substituting bracketed values):

```
Reflection complete.

- File changed:                `[relative path from workspace root]`
- Test added/updated:          `[relative path to the test script]`
- Tier:                        [core | agents/<name> | domains/<name>]
- Nature of the change:        [one sentence — WHAT was changed]
- Why it improves future runs: [one sentence — HOW it prevents the same friction]
- Friction it would have prevented: [one sentence — tied to the original task]
- Evolution report:            `.ai-suite/layer4-evolutionary/reflection/evolutions/REFLECTION-<timestamp>.md`

Please review the Git diffs manually before committing:
    git diff .ai-suite/
    git status .ai-suite/layer4-evolutionary/reflection/evolutions/
If the diff looks good, commit it yourself — I will NOT auto-commit:
    git add .ai-suite/<changed-file> .ai-suite/<test-file> .ai-suite/layer4-evolutionary/reflection/evolutions/REFLECTION-<timestamp>.md
    git commit -m "reflect: <one-line description of the improvement>"
```

---

## NON-NEGOTIABLES

- **One improvement per Reflection call.** Do not bundle unrelated edits — that defeats reviewability.
  If multiple Critical/High issues exist, address one and tell the user to run Reflection again.
- **No drive-by refactors.** Touch only the file announced as the improvement target.
- **No silent rewrites.** If an existing skill is materially restructured, call it out in the summary.
- **No reflection on a reflection.** Recursive self-reflection in the same turn is forbidden.
- **Frontmatter integrity.** After editing any skill, run `bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh`
  (no arguments). If it fails, fix the frontmatter before emitting the closing summary.
- **Tier integrity.** After editing, verify the file is in the correct tier directory.
  Core files must not contain agent-specific or domain-specific tokens.
- **Evolution report is mandatory.** Every Reflection call MUST write the report file.
  Do not skip it even if the change is small.

---

## DIAGNOSTIC HEURISTICS (use during Step 1)

A skill or template is a candidate for improvement when ANY of these is true:

| Symptom | Category | Likely Fix |
|---|---|---|
| AI asked a clarifying question it could have inferred | Instruction Completeness | Add assumption or stronger trigger to the skill |
| AI used the wrong skill | Trigger Accuracy | Tighten `description:` (keep "Use when …"); add `triggers:` entry |
| AI ran a destructive command without preflight | Safety Guard Gaps | Strengthen Safety Preflight; reference `production-safety.md` |
| AI's output was too verbose / fluffy | Output Quality | Add "no filler / density-optimised" constraint |
| AI hallucinated an API / package | Instruction Completeness | Add "MUST cite real path / verify before quoting" constraint |
| AI looped on the same failure 3+ times | Tool-Use Efficiency | Add circuit-breaker rule ("pivot after 3 identical failures") |
| AI missed a project-specific convention | Instruction Completeness | Add convention as hard constraint to the relevant skill |
| AI couldn't find the skill | Trigger Accuracy | Run `bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh`; check frontmatter |
| AI put agent-specific logic in a core skill | Tier Accuracy | Move agent content to `agents/<name>/`; keep core generic |
| AI put a general skill in an agent-specific directory | Tier Accuracy | Move general skill to `core/skills/` |
| AI improved Cursor behaviour but change also helps Claude | Tier Accuracy | Move improvement to `core/` if it truly applies to all agents |
| AI produced no copy-paste commands for the user | Output Quality | Add "always provide copy-paste commands" constraint to skill |
| Evolution report was missing or incomplete | Output Quality | This protocol needs strengthening (edit this file) |

---

## INVOCATION EXAMPLES

- *User: "Run Reflection. The last task spent five turns figuring out the setup process."*
  → Category: Instruction Completeness / High
  → Gate: Q1=YES → `core/`
  → Edit `.ai-suite/layer3-registry/core/testbed-setup.md` to mandate the setup path up-front.

- *User: "Reflect — you ran a command on a prod database without confirming."*
  → Category: Safety Guard Gaps / Critical
  → Gate: Q3=YES (Database) → `domains/database/`
  → Strengthen `.ai-suite/layer3-registry/domains/database/skills/db-setup.md` production guard.

- *User: "Improve the suite — tdd-team kept asking whether to commit."*
  → Category: Instruction Completeness / High
  → Gate: Q1=YES (TDD applies to all agents) → `core/`
  → Tighten "Default Stop Point" of `.ai-suite/layer3-registry/core/tdd-team.md`.

- *User: "Run Reflection — you put the new skill in .cursor/skills but it should be a core skill."*
  → Category: Tier Accuracy / High
  → Gate: Q1=YES (Applies to all agents) → `core/`
  → Edit `.ai-suite/layer1-abstraction/agents/cursor/skills/ai-suite-architect.md` to explicitly mandate the 3-Question Generality Gate when creating new skills.
