Feature: Prompt Enhancer / Meta-Cognitive Layer
  As a user interacting with the AI Suite
  I want to input a natural language prompt or ambiguous task
  So that the AI LLM agent can process it more effectively into a hyper-structured, execution-ready prompt

  Scenario: User requests to enhance a prompt
    Given the AI suite is enabled
    And the "prompt-enhancer" skill is available in core skills
    When the user inputs a natural language prompt and asks to "enhance prompt"
    Then the agent should analyze the input prompt
    And output an improved, highly structured prompt optimized for LLM execution
    And the improved prompt should include clear objectives, context, constraints, and output formatting

  Scenario: User requests to compile a task into a meta-prompt
    Given the AI suite is enabled
    When the user asks to "compile prompt" or needs an "AI-Easy-Understand" instruction set
    Then the agent should use the Context Aggregator to scan the workspace
    And output an execution prompt inside a "---START EXECUTABLE PROMPT---" block
    And the block should contain Role, Context, Chain-of-Thought Plan, and Constraints
