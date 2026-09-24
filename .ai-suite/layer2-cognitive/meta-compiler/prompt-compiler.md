---
name: prompt-compiler
description: Translate ambiguous tasks into hyper-structured execution prompts via Meta-Prompt Compiler. Use when compiling prompts, analyzing requirements, or optimizing prompts.
triggers:
  - compile prompt
  - enhance prompt
  - meta-cognitive
  - optimize prompt
  - AI-Easy-Understand
  - AI Expert
  - Prompt Architect
  - review enhancement
---

# Prompt Compiler / Meta-Cognitive Layer

Translate ambiguous human tasks into hyper-structured execution prompts optimized for LLM attention mechanisms.

## Step 1: Context Aggregator
Compile a focused project snapshot:
- **Semantic Exploration**: Use `Grep` or `Glob` to pinpoint relevant types, interfaces, and test contracts. Avoid dumping broad workspace directory trees into context.
- **Agent Context**: Summarize active capabilities and tools.

## Step 2: The Meta-Prompt Template
Wrap instructions inside an execution-ready Meta-Prompt:
- **Role & Context**: Persona definition and files to edit.
- **Objective**: Crisp, unambiguous goal.
- **Chain-of-Thought (CoT) Plan**: Step-by-step phases.
- **Strict Constraints**: Language formatting (`gofmt`, `clang-format`, clean blank lines without spaces/tabs to prevent gitreview red flags; format only new/modified lines), deterministic resource management (`defer`, context managers, `trap`), error wrapping, and dynamically computed test counts.
- **Expected Output Format**: Explicit presentation requirements.

## Step 3: Presentation & Execution
- Present compiled prompt enclosed in a `---START EXECUTABLE PROMPT---` block.
- Execute the compiled prompt only if explicitly instructed by the user.

## Instructions
Synthesize requirements into the structured meta-prompt template before output.

## Negative Constraints (Must NOT)
- [X] Do not skip the Context Aggregator step.
- [X] Do not execute the output prompt unless explicitly instructed by the user.
- [X] Do not output prompts without structured constraints and formatting standards.
