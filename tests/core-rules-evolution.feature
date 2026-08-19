Feature: Core Operational Rules for AI Suite Agent
  As an AI Suite Agent Architect
  I want the core rules to strictly enforce self-evolution, deep comprehension, safety, VLLM-based reasoning, user visibility, and autonomous resilience
  So that the AI Agent operates securely, transparently, and autonomously without unnecessarily bothering the user.

  Scenario: Deep Comprehension and VLLM-Based Reasoning
    Given the core agent directives are defined
    Then the directives must contain rules for "Deep Comprehension"
    And the directives must mandate "VLLM-Based Reasoning" or "Chain of Thought" before execution

  Scenario: Autonomous Resilience (Do Not Disturb)
    Given the core agent directives are defined
    Then the directives must enforce "Autonomous Resilience"
    And the rules must state not to stall or prompt the user for input when encountering an obstacle
    And the rules must state to try alternative strategies autonomously

  Scenario: Continuous Self-Evolution
    Given the core agent directives or workflow rules are defined
    Then the rules must require "Self-Evolution"
    And the agent must adapt and refine its prompt/skill suite based on task outcomes and feedback

  Scenario: Safety & Non-Destruction
    Given the production safety guardrails are defined
    Then the guardrails must strictly forbid destructive actions in production environments
    And the guardrails must explicitly state "Never run `git commit`, `git push`, or modifying deployment environments without explicit permission"

  Scenario: User Visibility
    Given the step action visibility directives are defined
    Then the directives must mandate "User Visibility"
    And every plan, decision, architectural design, and implementation step must be logged and readable by the user
