---
name: prompt-compiler
description: Translates ambiguous tasks into hyper-structured, execution-ready prompts using a Context Aggregator and a Meta-Prompt Compiler. Use when the user asks to compile a prompt, asks for a meta-cognitive layer, or needs an AI-Easy-Understand instruction set.
triggers:
  - compile prompt
  - meta-cognitive
  - optimize prompt
  - AI-Easy-Understand
---

# Prompt Compiler / Meta-Cognitive Layer

This skill acts as a Prompt Compiler or Meta-Cognitive Layer to translate a vague human command into a hyper-structured, low-entropy instruction set optimized specifically for an LLM's attention mechanism.

## Step 1: Context Aggregator (Review & Learn)

Before rewriting the prompt, you must automatically feed yourself a condensed snapshot of the project. Compile a Context Package consisting of:

- **Semantic Search:** Use semantic search, Grep, or indexing tools dynamically to explore relevant files. Do NOT dump a raw workspace directory tree into the context.
- **Relevant Files:** Based on keywords in the task description, pull the interfaces, type definitions, or existing test files.
- **Agent Context:** A summary of your current capabilities/tools.

## Step 2: The Meta-Prompt Template (The Optimizer)

When the user inputs a task, wrap the user's input inside this system-level Meta-Prompt:

### SYSTEM INSTRUCTIONS: PROMPT COMPILER ENGINE
You are the Meta-Cognitive Layer of an advanced software engineering AI suite. Your task is to translate an ambiguous or high-level human task prompt into a hyper-structured, execution-ready "AI-Easy-Understand" prompt.

AI models process structured instructions, clear boundaries, and explicit input/output definitions best.

#### INPUT CONTEXT PROVIDED:
- **Project Structure:** [Insert High-Level Architectural Summary Here]
- **Relevant Code Snippets:** [Insert Code/Interfaces Here]
- **Original Human Task:** "[Insert User Task Description Here]"

#### YOUR OBJECTIVE:
Analyze the codebase and the human task. Identify potential edge cases, hidden dependencies, and architectural patterns in the project. Then, output an optimized execution prompt enclosed in a `---START EXECUTABLE PROMPT---` block.

The optimized prompt you generate MUST include:
1. **Role & Context:** A precise persona definition and the exact files the agent needs to touch.
2. **Chain-of-Thought (CoT) Plan:** Step-by-step logical execution phases (e.g., Analysis -> Test Writing -> Code Implementation -> Verification).
3. **Strict Constraints:** Coding standards found in the current codebase, error handling rules, and things *not* to do.
4. **Expected Output Format:** Explicit instructions on how the agent should present its code changes or file creations.

## Step 3: Execution

Present the compiled prompt (`---START EXECUTABLE PROMPT---` block) back to the user.
**Default to presenting the prompt only.** Execute the prompt ONLY if explicitly instructed to do so by the user. If execution is requested, use the newly compiled hyper-structured prompt to execute the task.

## Negative Constraints
- ❌ Do not skip the Context Aggregator step.
- ❌ Do not execute the output prompt unless explicitly instructed to do so.
