# Integrate Capability Contracts

## 1. Skill Definition

**Path:** `.ai-suite/layer4-evolutionary/merging/integrate-capability.md`

### Required Frontmatter
```yaml
---
name: integrate-capability
description: Integrate the ai suite capabilities to an external agent by reviewing its directory, analyzing features, and merging capabilities without duplication.
triggers:
  - integrate ai suite
  - push capability
  - merge to external agent
---
```

### Required Sections
1. **Context/Background**: Explains the purpose of integrating ai suite capabilities to an external agent.
2. **Workflow**: Step-by-step instructions for the agent to fetch the remote config using shell tools, perform cross-comparison, merge capabilities in the sandbox, and push back using shell tools. Must mandate semantic cross-comparison (not just filename or content comparison) to identify synergistic capabilities.
3. **Safety Rules**: Must not break self evolution loop, must not create duplicate capabilities.
