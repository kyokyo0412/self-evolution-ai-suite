Feature: Dynamic Installation of AI Suite Directives and Safety Rules
  As an AI Suite user
  I want all directives and safety rules to be dynamically installed
  So that new rules are automatically deployed without modifying the installation scripts

  Scenario: Cursor adapter dynamically installs all directives and safety rules
    Given the ai-suite is installed for cursor
    When I check the `.cursor/rules` directory
    Then I should see `.mdc` files for all `.md` files in `layer3-registry/directives/`
    And I should see `.mdc` files for all `.md` files in `layer3-registry/safety/`
    And I should see `.mdc` files for all `.md` files in `layer1-abstraction/agents/cursor/rules/`

  Scenario: Core generate_markdown_block dynamically includes all directives and safety rules
    Given the ai-suite is installed for claude
    When I check the `CLAUDE.md` file
    Then it should contain the contents of all `.md` files in `layer3-registry/directives/`
    And it should contain the contents of all `.md` files in `layer3-registry/safety/`
