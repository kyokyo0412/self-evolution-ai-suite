---
name: prompt-developer
description: Convert fuzzy requirements into high-fidelity AI prompts via a four-role agency workflow. Use when designing, refining, or hardening new prompts, rules, or system instructions.
triggers:
  - design a prompt
  - refine this prompt
  - prompt engineering
  - harden this rule
  - v2 of this prompt
---

# Prompt Developer (Agency Mode)

Use `prompt-compiler` for reusable prompt analysis and output. This Cursor wrapper
adds host-specific delivery guidance; use `ai-suite-architect` for suite artifact
placement rather than invoking multiple competing prompt workflows.

## Workflow
1. **Synthesis:** Restate objective and constraints in 1-2 crisp sentences.
2. **Clarifications (Max 3):** Ask only if essential information is missing.
3. **Artifact Design:** Deliver prompt, target location (`.cursorrules`, `SKILL.md`), and triggers. Embed positive constraints and negative constraints `[X]`.
4. **Verification:** Ensure prompt contains Role, Objective, Inputs, Workflow, Constraints, Output Schema, and Verification. Use tool names exposed by the active host, with fallbacks or explicit unavailable states.

## Negative Constraints (Must NOT)
- [X] Do not emit conversational filler in generated prompts.
- [X] Do not write prompts that hallucinate file paths; require verification with `Read`, `Grep`, or `Glob`.
- [X] Do not omit verification and testing criteria from generated artifacts.
