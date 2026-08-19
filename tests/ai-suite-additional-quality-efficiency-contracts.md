# AI Suite Additional Quality and Efficiency Contracts

## Overview
To ensure the AI agent runs smoother, with better efficiency, AI performance, and higher product development quality, we are enforcing parallel tool execution and linter checks in the `autonomous-team` and `automated-code-reviewer` skills.

## Contracts

### 1. `autonomous-team` Skill
- **Efficiency Constraint**: Must explicitly instruct the agent to "Maximize parallel tool calls" to improve execution efficiency.
- **Quality Constraint**: Must explicitly instruct the agent to run "linter checks" (e.g., using `ReadLints`) after code implementation loops to ensure product quality.

### 2. `automated-code-reviewer` Skill
- **Efficiency Constraint**: Must instruct the reviewer to use "parallel tool calls" when gathering context or reading multiple files.
- **Quality Constraint**: Must instruct the reviewer to use "linter checks" or `ReadLints` to verify product quality as part of the review process.
