Feature: Meta Directory Installation
  As an AI suite user
  I want the meta directory files to be installed to the target location
  So that the reflection protocol and other meta files are available even if the source repository is deleted

  Scenario: Global install for cursor copies meta files
    Given I have a clean sandbox
    When I run ai-suite enable with scope global and agent cursor
    Then the directory ~/.cursor/meta should exist
    And the file ~/.cursor/meta/reflection-protocol.md should exist
    And the ~/.cursorrules file should reference ~/.cursor/meta

  Scenario: Project install for cursor copies meta files
    Given I have a clean sandbox
    And a target project directory
    When I run ai-suite enable with scope project and agent cursor targeting the project
    Then the directory <project>/.cursor/meta should exist
    And the file <project>/.cursor/meta/reflection-protocol.md should exist
    And the <project>/.cursorrules file should reference <project>/.cursor/meta

  Scenario: Global install for claude copies meta and skills files
    Given I have a clean sandbox
    When I run ai-suite enable with scope global and agent claude
    Then the directory ~/.claude/meta should exist
    And the directory ~/.claude/skills should exist
    And the ~/.claude/CLAUDE.md file should reference ~/.claude/meta
    And the ~/.claude/CLAUDE.md file should reference ~/.claude/skills

  Scenario: Project install for claude copies meta and skills files
    Given I have a clean sandbox
    And a target project directory
    When I run ai-suite enable with scope project and agent claude targeting the project
    Then the directory <project>/.claude/meta should exist
    And the directory <project>/.claude/skills should exist
    And the <project>/CLAUDE.md file should reference <project>/.claude/meta
    And the <project>/CLAUDE.md file should reference <project>/.claude/skills
