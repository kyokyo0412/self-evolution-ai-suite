# Architecture Contract: enhanced reflection-protocol.md
# Phase 2 artifact — structural and behavioral contracts.
# Verified by test-reflection-contracts.sh.

## File Location
  L1. Path: .ai-suite/layer4-evolutionary/reflection/reflection-protocol.md  (unchanged)
  L2. Not a skill file — no YAML frontmatter required
  L3. The file is the source of truth for ALL AI agents; must contain no
      agent-specific APIs (no .cursorrules, no ~/.cursor/)

## Structural Sections (all required, in order)

  S1.  Trigger block        — lists all recognised command strings
  S2.  ABSOLUTE PRECONDITIONS — mode-switch acknowledgement, refusal rule
  S3.  Step 1: 5-Category Analysis — named categories, severity tagging
  S4.  Step 2: Identify target — generality gate (3 questions), tier decision
  S5.  Step 3: Edit — file-editing rules, frontmatter preservation
  S6.  Step 4: Evolution report — write to layer4-evolutionary/reflection/evolutions/REFLECTION-*.md
  S7.  Step 5: Closing summary — format, what/why/tier, git commands
  S8.  NON-NEGOTIABLES — one-per-call, no auto-commit, etc.
  S9.  DIAGNOSTIC HEURISTICS — symptom → fix table

## 5-Category Analysis Contract (Step 1)

  A1. Category 1: Trigger Accuracy
        Was the correct skill found? Wrong skill used? Trigger mismatch?
  A2. Category 2: Instruction Completeness
        Were all steps present? Missing context, missing examples, ambiguous instructions?
  A3. Category 3: Safety Guard Gaps
        Destructive/irreversible action without preflight? Missing production guard?
  A4. Category 4: Tool-Use Efficiency
        Excessive re-reads, redundant terminal calls, unnecessary clarification questions?
  A5. Category 5: Output Quality
        Result clear and actionable? Verbose? Did it leave the user with copy-paste commands?
  A6. Each finding tagged: Critical | High | Medium | Low
  A7. Only Critical / High findings drive the improvement target selection

## Generality Gate Contract (Step 2)

  G1. Four questions asked before choosing the improvement target:
        Q1. Applies to all agents (general skills/prompts)? → .ai-suite/core/
        Q2. Is it a task process procedure (TDD, SWE, quality)? → .ai-suite/layer3-registry/core/
        Q3. Agent-specific (e.g. Cursor)? → .ai-suite/layer1-abstraction/agents/<name>/
        Q4. Domain-specific (e.g. CustomDomain vendor knowledge)? → .ai-suite/layer3-registry/domains/<name>/
  G2. Gate result MUST be stated before any edit begins
  G3. New file creation MUST include tier justification in the closing summary
  G4. Core files must not contain Cursor-specific tokens or domain system names

## Evolution Report Contract (Step 4 — new step)

  R1. File path: .ai-suite/layer4-evolutionary/reflection/evolutions/REFLECTION-<timestamp>.md
  R2. Required sections in the report:
        - ## Task Summary
        - ## Improvement Target       (path + tier)
        - ## Root Cause               (which of the 5 categories + severity)
        - ## Change Description       (what was edited and why)
        - ## Generality Gate Result   (tier chosen + justification)
        - ## Delta Summary            (key text additions/removals)
  R3. Report is co-located with remote evolution reports (same directory)
      so ai-suite evolve collect can pick it up from remote instances
  R4. Closing summary MUST list the report filename for git add

## Closing Summary Format Contract (Step 5)

  CS1. Must contain: "File changed:"
  CS2. Must contain: "Nature of the change:"
  CS3. Must contain: "Why it improves future runs:"
  CS4. Must contain: "Friction it would have prevented:"
  CS5. Must contain: "Tier:" (new — states which tier was chosen)
  CS6. Must contain: "Evolution report:"  (new — lists report path)
  CS7. Must contain the git diff instruction
  CS8. Must contain "NOT auto-commit" or equivalent

## Backward Compatibility Contracts

  BC1. Triggers unchanged: "Run Reflection", "Reflect on the last task",
       "Improve the suite", "运行反思"
  BC2. One-improvement-per-call rule preserved
  BC3. No auto-commit rule preserved
  BC4. validate-suite.sh called with NO ARGUMENTS (scans all three tiers)
       NOT with a single-dir argument (old flat layout)
  BC5. ai-suite enable / ai-suite disable / ai-suite evolve NOT mentioned
       as improvement targets in the reflection (they are infrastructure)
  BC6. Protocol has no Cursor-specific paths (no .cursorrules, ~/.cursor)

## Agent-Agnostic Language Contract

  AG1. Protocol body must NOT contain tokens: ".cursorrules", "~/.cursor/"
  AG2. Protocol references tiers by neutral path: core/, agents/, domains/
  AG3. All examples use tier-aware paths, not flat .ai-suite/skills/ paths
