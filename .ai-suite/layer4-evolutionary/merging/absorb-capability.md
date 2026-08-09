---
name: absorb-capability
description: Ingest, deduplicate, and merge capabilities from an external agent into the AI suite Agent using semantic analysis and deep architectural integration. Use when the user asks to absorb, ingest, or fetch capabilities from an external agent's configuration directory.
triggers:
  - absorb capability
  - absorb agent
  - ingest external agent
  - absorb from
---

# Absorb Capability — External Agent Ingestion Engine (V2)

Orchestrate the ingestion and structural evolution of external agent capabilities into the AI suite Agent.

## Role

Act as the Absorbing Engine. When triggered, you execute a strict 5-phase workflow to fetch, semantically analyze, architecturally integrate, verify, and report on the ingestion of external capabilities (e.g., from a remote `.cursor` folder) into your own configuration.

---

## Trigger Recognition

This skill is active when the user says:
- "Absorb agent from user@host at /opt/agent/.cursor"
- "Ingest external agent capabilities from user@host path /etc/.cursor"
- "Absorb the agent in current project"
- "Absorb the local agent"

## Instructions

### Phase A: Remote or Local Inspection (Fetch)
1. Determine if the user is asking for a local or remote absorb.
2. Create a temporary sandbox directory using your shell tool: `SANDBOX=$(mktemp -d /tmp/ai-suite-absorb-XXXXXX)`
3. For remote absorb, extract the `USER@HOST` and `PATH` from the user's request and use your shell tool to fetch:
   `rsync -az -e "ssh -o BatchMode=yes -o ConnectTimeout=10" USER@HOST:PATH/ $SANDBOX/`
4. For local absorb, use your shell tool to copy the local configuration files (including skills, rules, scripts, templates) to the sandbox:
   `cp -r .cursor .cursorrules .cursor/rules .cursor/skills .cursor/templates .cursor/scripts .continue .claude CLAUDE.md .opencode .roorules $SANDBOX/ 2>/dev/null || true 2>/dev/null || true`

### Phase B: Robust Semantic Mapping & Deep Learning
1. Use your `Glob`, `Read`, and `SemanticSearch` tools on the sandbox directory and your own capabilities (e.g., `~/.cursor/skills/`, `~/.cursor/rules/`, `~/.cursor/templates/`, `~/.cursor/scripts/`).
2. Extract the core intent, pre-conditions, logic paths, and intended outcomes of each capability in both the sandbox and your own configuration. Disregard file boundaries and naming conventions.
3. Build a comprehensive **semantic map** in your context that links the operational semantics and structural logical flows of both sources.
4. Identify synergistic intersections where external logic can structurally enhance your own capabilities.

### Phase C: Fundamentally Grounded Semantic Integration
1. Do not merely append code or perform 1-to-1 file merges. Instead, **synthesize and master** the capabilities to drive a new round of evolution.
2. Based on your semantic map, reconstruct the capabilities into a superior, optimized evolutionary state for yourself. This new form should offer superior usability and efficiency.
3. **Merge Destination**:
   - **Special Case**: If you are an AI suite developing agent (i.e., `.ai-suite/` exists in your workspace), you MUST merge the new capabilities into BOTH the developing AI suite source code (`.ai-suite/`) AND the Host agent configuration (e.g., `.cursor/`, `.continue/`, `.claude/`).
   - Otherwise, merge the new capabilities into your own configuration (e.g., `~/.cursor/skills/`, `~/.cursor/rules/`, `~/.cursor/templates/`, `~/.cursor/scripts/`).
4. **Self-Evolution Priority:** No architectural change or external logic may disrupt, deprecate, or bypass your capability to evolve further.

### Phase D: Evolution Verification (TDD)
1. Define concrete test scenarios and verification matrices (using bash scripts or feature files) that validate the performance, efficiency, and usability of the newly evolved capabilities.
2. Run these validation checks continuously during the evolution cycle.

### Phase E: Evolution Reporting
1. Compile a granular, technical report detailing the architectural mutations, performance deltas, and test coverage results.
2. Remove the temporary sandbox directory: `rm -rf /tmp/ai-suite-absorb-...`
3. Print a summary of absorbed capabilities to the user.

## Negative Constraints (Must NOT)
- Do not modify `evolve_suite.sh` or break the existing evolutionary loop.
- Do not auto-commit the changes.
- Do not merge duplicate capabilities without synthetically unifying them if there are semantic differences.
