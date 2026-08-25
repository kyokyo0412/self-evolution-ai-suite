---
name: integrate-capability
description: Integrate your own capabilities (as an AI suite Agent) to an external agent by reviewing its directory, analyzing features, and merging capabilities without duplication. Use when you need to integrate or push your capabilities to an external agent.
triggers:
  - integrate ai suite
  - push capability
  - merge to external agent
---

# Integrate Capability

This skill allows you (the AI suite Agent) to integrate your own capabilities into an external agent's configuration directory (e.g., a `.cursor` directory on a remote host), transforming the external agent into a new AI suite Agent.

## Context

The AI suite is a tool for self evolution. It can push itself to different hosts and agents. This skill specifically handles integrating your capabilities (skills, prompts, scripts, rules) into an external agent, ensuring no duplicate capabilities are created and the target agent structure aligns with your own capabilities.

## Workflow

1. **Fetch Remote Configuration**:
   Use your shell tools to fetch the external agent's configuration into a local temporary sandbox:
   ```bash
   SANDBOX_DIR=$(mktemp -d /tmp/ai-suite-integrate-XXXXXX)
   scp -r <user@host>:<path/to/.cursor>/* $SANDBOX_DIR/ || true
   ```

2. **Fundamentally Robust Semantic Cross-Comparison**:
   - Deeply read and analyze the capabilities in both the fetched sandbox and your own configuration using `SemanticSearch` and `Read` tools.
     - **Special Case**: If you are an AI suite developing agent (i.e., `.ai-suite/` exists in your workspace), you MUST source your capabilities ONLY from the AI suite source code (e.g., `.ai-suite/`). You MUST NOT include any items from the Host agent configuration (e.g., `.cursor/`, `.continue/`, `.claude/`).
     - Otherwise, use your active configuration (e.g., `~/.cursor/skills/`, `~/.cursor/rules/`, `~/.cursor/templates/`, `~/.cursor/scripts/`).
   - Extract the core semantic intent, workflows, and logical constraints of each capability. Disregard file names, boundaries, and superficial content.
   - Perform a semantically grounded cross-comparison to identify synergies, gaps, and structural overlaps between your capabilities and the external agent.
   - Synthesize these capabilities by deeply integrating and mastering them, planning a unified architectural model for the target agent that represents a superior evolutionary state.

3. **Prepare Sandbox**:
   - Copy the necessary files from your own configuration to the sandbox directory using your shell tools.
     - **Special Case**: If you are an AI suite developing agent, copy ONLY from the AI suite source code (`.ai-suite/`).
   - Ensure the structure matches the expected format for the target agent, transforming it into a new AI suite Agent.

4. **Push Sandbox**:
   Push the modified sandbox back to the external agent using your shell tools:
   ```bash
   ssh <user@host> "mkdir -p <path/to/.cursor>"
   scp -r $SANDBOX_DIR/* <user@host>:<path/to/.cursor>/
   ```

5. **Cleanup**:
   Remove the temporary sandbox directory using your shell tool: `rm -rf $SANDBOX_DIR`

## Safety Rules

- **Self Evolution Priority**: The self evolution is the highest priority core function, NEVER forget or break it.
- **No Duplicates**: Avoid creating duplicate capabilities. If capabilities are duplicate, integrate them to make the target agent structure the same as your own.
- **No Unintended Modifications**: Do not modify files outside the target agent's configuration directory.

## Negative Constraints (Must NOT)
- [X] Do not create duplicate capabilities.
- [X] Do not modify files outside the target agent's configuration directory.
- [X] Do not proceed with the integration if the remote fetch fails silently.
- [X] Do not omit boundary validation when analyzing semantic overlap (if confidence is low, gracefully abort or prompt for clarification).
