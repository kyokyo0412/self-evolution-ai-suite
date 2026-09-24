---
name: integrate-capability
description: Integrate AI suite capabilities into an external agent directory without duplication. Use when integrating or pushing suite capabilities to an external agent.
triggers:
  - integrate ai suite
  - push capability
  - merge to external agent
---

# Integrate Capability

Integrate AI suite capabilities into an external agent's configuration directory (e.g., `.cursor` on a remote host).

## Context
Enables distributing capabilities (skills, prompts, scripts, rules) to an external agent without duplicates or structure conflicts.

## Workflow
1. **Fetch:** `SANDBOX_DIR=$(mktemp -d /tmp/ai-suite-integrate-XXXXXX) && scp -r <user@host>:<path/to/.cursor>/* $SANDBOX_DIR/ || true`
2. **Cross-Comparison:** Compare fetched capabilities with source capabilities using `Read` and `Glob` without duplication. For developing suite agent, source exclusively from `.ai-suite/`.
3. **Push:** Copy required files to sandbox and push: `ssh <user@host> "mkdir -p <path/to/.cursor>" && scp -r $SANDBOX_DIR/* <user@host>:<path/to/.cursor>/`
4. **Cleanup:** `rm -rf $SANDBOX_DIR`

## Safety Rules & Negative Constraints (Must NOT)
- [X] Do not create duplicate capabilities.
- [X] Do not modify files outside the target agent's configuration directory.
- [X] Do not proceed with the integration if the remote fetch fails silently.
- [X] Do not omit boundary validation when analyzing semantic overlap.
