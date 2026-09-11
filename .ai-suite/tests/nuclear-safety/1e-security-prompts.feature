Feature: Enforce 1E-Class Security Standards on AI Suite Prompts, Skills, and Directives
  In order to ensure LLMs execute tasks deterministically and safely
  As a PM enforcing the nuclear-safety.md directive on markdown assets
  I want all AI prompt files (skills, directives, templates) to contain explicit defensive constraints

  Scenario: Defensive Prompting via Negative Constraints
    Given an AI suite skill or directive markdown file
    When it is evaluated for safety
    Then it MUST contain a "Negative Constraints (Must NOT)" section to enforce boundary limits on the agent
    And the file MUST explicitly mention error handling or validation

  Scenario: Template Formalization
    Given a cognitive template file
    When it is evaluated for safety
    Then it MUST contain structured sections that prevent unbound outputs (e.g. constraints, expected formats)
