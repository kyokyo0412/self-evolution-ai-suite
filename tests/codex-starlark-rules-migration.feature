Feature: Codex Rules Separation and AGENTS.md Markdown Migration
  As an AI Suite Architect and Codex Integration Lead
  I want all AI Suite markdown rules to be migrated into Codex's AGENTS.md prompt file
  And ensure .codex/rules contains no markdown prompt rules, reserving it for Codex Starlark execution rules
  So that Codex agent functions correctly with full directives/rules without syntax corruption or execution conflicts.

  Background:
    Given the AI Suite framework is available
    And the Codex agent adapter is invoked for project or global installation

  Scenario: Migration of all markdown rules into AGENTS.md prompt file
    When the AI suite is enabled for Codex agent
    Then the AGENTS.md file must contain all inlined directives and safety rules
    And the AGENTS.md file must contain all general, cognitive, and evolutionary markdown rules
    And all inlined rules in AGENTS.md must have YAML frontmatter stripped
    And the AGENTS.md file must have a structured "## AI Suite Directives & Rules" section

  Scenario: Zero markdown prompt rules in .codex/rules directory
    When the AI suite is enabled for Codex agent
    Then the .codex/rules directory must not contain any .md or .mdc markdown prompt files
    And the .codex/rules directory must be reserved for Starlark-syntax execution rules

  Scenario: Complete installation of other AI Suite components for Codex
    When the AI suite is enabled for Codex agent
    Then the .codex/skills directory must be populated with available skills
    And the .codex/templates directory must be populated with cognitive templates
    And the .codex/scripts directory must be populated with executable cognitive memory scripts
    And the .codex/meta directory must be populated with validation and reflection protocols
    And the .codex/directives directory must be populated with mirrored directives

  Scenario: Clean uninstallation of Codex components
    When the AI suite is disabled for Codex agent
    Then the ai-suite block in AGENTS.md must be cleanly removed
    And the .codex/skills directory must be removed
    And the .codex/templates directory must be removed
    And the .codex/scripts directory must be removed
    And the .codex/meta directory must be removed
    And the .codex/directives directory must be removed
    And any AI suite files in .codex/rules must be cleaned up

  Scenario: Published package installation domain isolation
    When a published package is created and installed into a Codex project
    Then the AGENTS.md file must be populated without any VMware or Broadcom domain rules
    And the .codex/ directory must contain zero VMware or Broadcom domain files
