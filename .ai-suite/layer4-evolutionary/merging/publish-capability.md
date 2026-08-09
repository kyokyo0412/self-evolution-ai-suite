---
name: publish-capability
description: Publish the AI suite capabilities from the current AI suite Agent to an AI suite publish package. Use when you need to publish, package, or export the AI suite capabilities.
triggers:
  - publish capability
  - publish ai suite
  - export agent
  - package capabilities
---

# Publish Capability

This skill allows the AI suite Agent to publish its capabilities into a distributable AI suite package.

## Context

The AI suite Agent can publish its capabilities to an AI suite publish package. If the agent is an AI suite developing agent (i.e., `.ai-suite/` exists in the workspace), it publishes the developing AI suite. If it is a normal AI suite Agent, it publishes its own configuration (e.g., `~/.cursor/skills/`, `~/.cursor/rules/`, `~/.cursor/templates/`, `~/.cursor/scripts/`).

## Workflow

1. **Determine Agent Type**:
   - Check if `.ai-suite/` exists in the current workspace. If so, it is an AI suite developing agent.
   - Otherwise, it is a normal AI suite Agent.

2. **Publish from AI suite developing agent**:
   - Run the `publish_suite.sh` script in the workspace root.
   - `bash publish_suite.sh`

3. **Publish from normal AI suite Agent**:
   - Create a temporary directory for the package structure.
   - Reconstruct the `.ai-suite/` structure from the agent's configuration (e.g., `~/.cursor/skills/` -> `.ai-suite/layer1-abstraction/agents/cursor/skills/`, `~/.cursor/rules/` -> `.ai-suite/layer1-abstraction/agents/cursor/rules/`, `~/.cursor/meta/` -> `.ai-suite/layer4-evolutionary/validation/`).
   - Ensure the package MUST NOT contain any domains (`layer3-registry/domains`) to avoid copyright issues.
   - Create a tarball named `ai-suite-package.tar.gz`.

4. **Cleanup**:
   - Remove any temporary directories.
   - Notify the user of the published package location.

## Safety Rules

- **Self Evolution Priority**: The self evolution is the highest priority core function, NEVER forget or break it.
- **No Unintended Modifications**: Do not modify the source capabilities during publishing.
