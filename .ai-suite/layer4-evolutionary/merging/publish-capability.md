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

Publish AI suite capabilities into a distributable AI suite package.

## Context
Packages suite capabilities for distribution. For developing suite agents (`.ai-suite/` present), packages from source repository. For normal agents, exports installed agent capabilities.

## Workflow
1. **Determine Agent Type:**
   - Developing agent: `.ai-suite/` exists in workspace root; run `bash ai-suite publish`.
   - Normal agent: export installed capabilities (`~/.cursor/skills/`, `~/.cursor/rules/`), reconstruct `.ai-suite/` tree in a temporary directory excluding domains (`layer3-registry/domains`), and package into `ai-suite-package.tar.gz`.
2. **Cleanup & Report:** Clean up temporary directories and report artifact location.

## Safety Rules & Negative Constraints (Must NOT)
- [X] Do not modify the source capabilities during publishing.
- [X] Do not publish any domains (`layer3-registry/domains`) to avoid copyright or data leaks.
- [X] Do not leave temporary directories behind if the archiving process fails.
