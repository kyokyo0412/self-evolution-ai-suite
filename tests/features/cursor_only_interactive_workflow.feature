Feature: Cursor-Only Interactive Workflow Isolation

  As an AI suite developer and user
  I want the interactive workflow to be exclusively configured and activated for Cursor Agent
  So that non-Cursor agents (Codex, Claude Code, Roo-Code, OpenCode, Continue) execute tasks cleanly without receiving or activating Cursor-specific interactive workflow rules, while Cursor retains zero-cost interactive refinement.

  Background:
    Given the AI Suite framework supports multiple agent abstractions: cursor, codex, claude, roo-code, opencode, continue

  Scenario: Non-Cursor agent configuration generation strictly excludes interactive workflow directives
    When an AI Suite configuration is generated for a non-Cursor agent ("codex", "claude", "roo-code", "opencode", "continue")
    Then the generated configuration files (AGENTS.md, CLAUDE.md, .roorules, instructions.md, ai-suite.prompt) MUST NOT contain:
      | pattern |
      | interactive-workflow |
      | interactive workflow |
      | AskQuestion |
      | State 0 - INITIALIZATION |
      | State 1 - NORMAL |
      | State 2 - WRAP-UP |
      | State 3 - THE FOLLOW-UP LOOP |
    And the non-Cursor agent instructions MUST strictly instruct standard single-task execution.

  Scenario: Universal registry directives are clean and agent-agnostic
    When the universal agent directives file (.ai-suite/layer3-registry/directives/agent-directives.md) is inspected
    Then it MUST NOT contain:
      | pattern |
      | AskQuestion |
      | Continuous Interactive Workflow Persistence |
      | Do not terminate turn without AskQuestion |
      | Active Task Cleanup Before AskQuestion |
    And it MUST contain universal directives for workspace cleanup, version control, code quality, and testing.

  Scenario: Cursor Agent retains full interactive workflow capabilities
    When the Cursor Agent rule (.ai-suite/layer1-abstraction/agents/cursor/rules/interactive-workflow.md) is deployed
    Then it MUST contain:
      | pattern |
      | State 0 - INITIALIZATION (Hard Block) |
      | State 1 - NORMAL / MAIN TASK EXECUTION |
      | State 2 - WRAP-UP & SUMMARY ISOLATION |
      | State 3 - THE FOLLOW-UP LOOP |
      | strictly and ONLY for the Cursor Agent |
      | Must not cost any extra Cursor included request |
    And it MUST be deployed to Cursor rules directory as "cursor-suite-interactive-workflow.mdc".

  Scenario: Loop-work skill executes cleanly on non-Cursor agents without AskQuestion
    When the loop-work skill is executed by a non-Cursor agent
    Then the agent MUST execute all N iterations without attempting to invoke AskQuestion or trigger interactive workflow states
    And when executed by Cursor Agent with interactive workflow active, it MUST adhere to State 2 summary and State 3 AskQuestion isolation.
