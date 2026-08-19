# AI-Expert Integration Contracts

The `ai-expert` role must be deeply integrated into the following core files:

1. **Reflection Protocol** (`.ai-suite/layer4-evolutionary/reflection/reflection-protocol.md`):
   - Step 3 (Edit the Skill / Template / Meta File) must explicitly instruct the AI to assume the AI-Expert role to review the enhancement and confirm it improves the AI agent's working capabilities.

2. **Global AI Suite Block** (`.ai-suite/layer2-cognitive/memory/core.sh` -> `generate_markdown_block`):
   - The generated markdown block must include an `### AI-Expert Prompt Optimization` section.
   - It must instruct the agent to automatically apply the `ai-expert` skill to analyze and optimize the user's request before executing complex tasks.

3. **TDD Team Process** (`.ai-suite/layer3-registry/core/tdd-team.md`):
   - Phase 1.1 (Define) must instruct the PM to consult the AI-Expert role to optimize the user's initial prompt and requirements.

4. **Autonomous Team Process** (`.ai-suite/layer3-registry/core/autonomous-team.md`):
   - Phase 1 (Requirements) must instruct the PM to consult the AI-Expert role to optimize the user's initial prompt and requirements.
