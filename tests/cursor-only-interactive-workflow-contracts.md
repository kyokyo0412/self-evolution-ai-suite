# Cursor-Only Interactive Workflow Isolation Architecture & Contracts

## 1. Architectural Problem & Isolation Invariant

### 1.1 Root Cause Analysis
Previously, Cursor-specific interactive workflow directives and `AskQuestion` tool requirements were placed inside `.ai-suite/layer3-registry/directives/agent-directives.md`. Because Layer 3 directives are universal registry artifacts mirrored to all agent adapters (`codex`, `claude`, `roo-code`, `opencode`, `continue`) and embedded via `generate_markdown_block()`, non-Cursor agents inadvertently received instructions referencing `AskQuestion` and mandatory interactive workflow loops.

### 1.2 Isolation Invariant
- **Cursor Agent Exclusivity**: The Interactive Workflow is strictly and ONLY for the Cursor Agent.
- **Universal Layer 3 Purity**: Universal directives (`agent-directives.md`, `code-quality.md`, `nuclear-safety.md`, `step-action-visibility.md`) and safety guardrails (`production-safety.md`) must be 100% agent-agnostic and contain zero mentions of `AskQuestion` or `interactive-workflow`.
- **Layer 1 Cursor Encapsulation**: All interactive workflow state machines (State 0, State 1, State 2, State 3), AskQuestion constraints, loop persistence, and cleanup barriers are strictly encapsulated in `.ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md` (deployed as `cursor-suite-interactive-workflow.mdc`).
- **Loop-Work Dual Compatibility**: `loop-work.md` in Layer 3 specifies interactive workflow wrap-up ONLY when running under Cursor Agent with interactive workflow active; for non-Cursor agents, it executes all $N$ iterations and outputs the final execution summary directly to chat.

## 2. Contract Specifications

### 2.1 Universal Directive Contract (`agent-directives.md`)
- Must contain universal directives: Version Control, Communication/Reporting, Multi-Skills, Verification, Deep Comprehension, Autonomous Resilience, Self-Evolution, Workspace Cleanup, Efficiency, AI-Review, Task Tracking, Formatting, Deterministic Resources, Dynamic Assertions.
- Must NOT contain Section 15 (`Continuous Interactive Workflow Persistence (Cursor Agent)`).
- Must NOT reference `AskQuestion` in Section 8 or Negative Constraints.

### 2.2 Cursor Interactive Workflow Contract (`interactive-workflow.md`)
- State 0: Mandatory `AskQuestion` initialization with prompt and yes/no options.
- State 1: Silent main task execution (Daemon mode) with zero behavioral deviation from standard execution.
- State 2: Visible text summary in chat + UI synchronization tool (`echo 'Interactive workflow summary rendered'`).
- State 3: Next-turn `AskQuestion` follow-up tool call.
- Continuous Loop: "Other" custom text is executed as a NEW TASK following Step 1 -> Step 2 -> Step 3 continuously without re-prompting Step 0.
- Zero-Cost Guarantee: Zero extra Cursor request consumption.

### 2.3 Non-Cursor Adapter Output Contract
When `ai-suite enable` or `generate_markdown_block` runs for `codex`, `claude`, `roo-code`, `opencode`, `continue`:
- Generated configuration files (`AGENTS.md`, `CLAUDE.md`, `.roorules`, `.continue/prompts/ai-suite.prompt`, `.opencode/instructions.md`) must contain 0 occurrences of `interactive-workflow`, `interactive workflow`, and `AskQuestion`.
