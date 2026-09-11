Feature: Codex Agent Support
  As a user of the AI Suite
  I want to be able to enable and disable the AI Suite for the Codex agent
  So that I can use the AI Suite's capabilities within Codex

  Scenario: Enable AI Suite for Codex in project scope
    Given I have a project directory
    When I run "ai-suite enable --agent codex --scope project"
    Then the AI Suite should be installed for Codex in the project
    And an "AGENTS.md" file should be created or updated with the AI Suite block
    And the ".codex/skills" directory should be populated

  Scenario: Disable AI Suite for Codex in project scope
    Given I have a project directory with Codex enabled
    When I run "ai-suite disable --agent codex --scope project"
    Then the AI Suite block should be removed from "AGENTS.md"
    And the ".codex/skills" directory should be removed
