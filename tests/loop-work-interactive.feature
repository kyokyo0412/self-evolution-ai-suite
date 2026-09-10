Feature: Loop-Work and Interactive Workflow Robustness

  As an AI developer using Cursor Agent
  I want loop-work and interactive-workflow to reliably cooperate
  So that when all loop iterations finish, a full summary is output to the chat window before AskQuestion,
  And when I answer via the 'Other' option, the Agent performs the task and persistently triggers AskQuestion again.

  Scenario: Loop-work completes all iterations and outputs full summary before AskQuestion
    Given interactive workflow is active in Cursor Agent
    When loop-work finishes all N requested iterations
    Then the agent MUST explicitly write the complete loop-work execution summary in chat window text
    And the agent MUST call "echo 'Interactive workflow summary rendered'" to force UI rendering
    And the agent MUST NOT call AskQuestion until after the summary is rendered in chat
    And the agent MUST call AskQuestion in the subsequent response.

  Scenario: Persistent interactive workflow after executing a task from the Other option
    Given the user selects the "Other" option in AskQuestion with a custom task prompt
    When the agent receives the custom prompt
    Then the agent treats it as a NEW TASK in Step 1 (Daemon Mode)
    And the agent MUST execute the task completely with full tool access
    And the agent MUST proceed to Step 2 to output the execution summary in chat and call the UI sync echo
    And the agent MUST proceed to Step 3 to invoke AskQuestion again
    And the agent is STRICTLY FORBIDDEN from ending the turn or stopping without invoking AskQuestion.

  Scenario: Strict Cursor Agent isolation and zero cost refinement
    Given the interactive workflow is enabled in the workspace
    When inspecting configuration and adapter logic for Codex or non-Cursor agents
    Then the interactive workflow rule MUST NOT be deployed to or required for Codex
    And the interactive workflow MUST NOT cost any extra Cursor included requests
    And follow-up tasks MUST NOT re-prompt Step 0 initialization.

  Scenario: Explain option execution fidelity
    Given the user selects the "explain" option in AskQuestion
    When the agent processes the selection
    Then the agent MUST provide the detailed explanation in chat text
    And the agent MUST call "echo 'Interactive workflow summary rendered'" or directly invoke AskQuestion
    And the interactive workflow loop MUST remain open.
