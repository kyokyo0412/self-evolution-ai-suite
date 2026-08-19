# Prompt Enhancer & Meta-Cognitive Layer Skill Architecture Contracts

## Contract 1: File Location and Naming
The skill MUST be placed in `.ai-suite/layer2-cognitive/meta-compiler/prompt-enhancer.md` as it is a universal, agent-agnostic skill.

## Contract 2: Frontmatter Structure
The markdown file MUST include standard AI Suite YAML frontmatter containing:
- `name: prompt-enhancer`
- `description:` starting with a verb, explaining its purpose (e.g., "Analyze and improve natural language prompts for AI agents").
- `triggers:` array containing keywords like "enhance prompt", "improve prompt", "compile prompt", "meta-cognitive".

## Contract 3: Skill Content
The skill content MUST contain:
- Instructions on how to analyze the input prompt.
- The structure of the enhanced prompt to output (e.g., Context, Objective, Constraints, Output Format).
- The Context Aggregator instructions for compiling a Meta-Prompt from the codebase.
- The expected execution block `---START EXECUTABLE PROMPT---`.
- No hardcoded agent-specific features (must work across Claude, Cursor, etc.).
