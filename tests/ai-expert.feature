Feature: AI-Expert Role
  As a user of the ai-suite
  I want an AI-Expert role (Prompt Architect)
  So that it can analyze my requests, identify prompt vulnerabilities, output highly structured agent prompts, and review ai-suite enhancements.

  Scenario: AI-Expert skill is available as a core skill
    Given the ai-suite is installed
    When I look for the "ai-expert" skill in the core skills directory
    Then I should find the skill definition
    And the skill should describe its role as AI Expert and Prompt Architect
    And the skill should explain how it analyzes requests and outputs structured prompts
    And the skill should explain how it reviews ai-suite enhancements
    And the skill should be automatically integrated into the ai-suite workflow

  Scenario: AI-Expert skill triggers
    Given the "ai-expert" skill exists
    When I provide a trigger like "AI Expert" or "Prompt Architect"
    Then the skill should be activated
