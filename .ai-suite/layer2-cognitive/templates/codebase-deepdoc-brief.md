# Template: Engage the `codebase-deepdoc` Skill (Brief Form)

**Purpose:** A short trigger brief for when you want to explicitly invoke the `codebase-deepdoc` skill on a specific scope (subdir, language layer, or whole repo). The full instruction set lives in `.cursor-suite/skills/codebase-deepdoc.md` — this template just sets the scope and any deviations.

Paste this into Cursor (Agent Mode), fill the `[BRACKETS]`, and submit.

---

Use the **`codebase-deepdoc`** skill on `@codebase` (or restrict to `@[SCOPE_PATH]`).

**Scope:** `[whole repo | path/to/subtree | specific module name]`
**Audience priority:** `[non-tech onboarding | architects | new engineers | operators]` (skill will cover all five, but prioritize this one if context tightens)
**Output directory:** `aigen_doc/`
**Special instructions (optional):** `[e.g. "skip the legacy module under crx/old/", "emphasize the dataplane components", "all Mermaid diagrams in C4 notation"]`

Begin Phase 0 immediately. Do not pause between phases. If the codebase is huge, prioritize: inventory → Layer 1 → critical-path components → support components.

When done, confirm completeness with:
```bash
ls aigen_doc/docs/components/*/ | xargs -I{} ls {}/0{1,2,3,4,5}_*.md
find aigen_doc -name '*.md' -size -200c
```
