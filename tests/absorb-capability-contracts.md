# Interface Contracts: Absorbing Capability

## 1. Skill Definition Contract: `layer3-registry/core/absorb-capability.md`

**Required Fields:**
- `name: absorb-capability`
- `description: ...`
- `triggers:`
  - `absorb capability`
  - `absorb agent`
  - `ingest external agent`

**Behavioral Requirements:**
- Must explicitly instruct the agent to use shell tools like `rsync`, `cp`, or `scp`.
- Must mandate the "Self-Comparison & De-duplication" step (prevent duplicate skills/rules).
- Must mandate content-based comparison (not just filename comparison) to identify duplicate capabilities.
- Must explicitly forbid modifying existing files or auto-committing.
