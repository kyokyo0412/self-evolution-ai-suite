Feature: ASCII Cleanliness and Codex Agent Instructions Migration
  As a developer and AI agent framework user
  I want all files in the AI suite to use clean ASCII encoding without invisible or corrupted characters
  And I want the Codex agent to use standard AGENTS.md instruction files with all directives and safety rules migrated
  So that all agents (Cursor, Claude, OpenCode, Continue, Roo-Code, Codex) work reliably across all environments

  Scenario: All files across the AI Suite and tests are strictly valid ASCII
    Given the codebase contains scripts, templates, rules, skills, tests, and documentation
    When the ASCII validation script scans every file in the repository
    Then no non-ASCII characters or invisible/corrupted byte sequences should be present in any file

  Scenario: Codex Agent installs project-level instructions into AGENTS.md
    Given a clean target project directory
    When I run "ai-suite enable --agent codex --scope project --project <TARGET>"
    Then the file "AGENTS.md" should be created in the target project directory
    And "AGENTS.md" should contain the AI Suite start sentinel "<!-- ai-suite:start -->" and end sentinel "<!-- ai-suite:end -->"
    And "AGENTS.md" should contain the mirrored skills index, memory system, proactive resolution, and auto-evolution directives
    And "AGENTS.md" should contain all core directives and safety rules
    And the directory ".codex/skills" should be populated with mirrored skills
    And the directory ".codex/meta" should be populated with metadata

  Scenario: Codex Agent installs global instructions into ~/.codex/AGENTS.md
    Given an isolated HOME environment
    When I run "ai-suite enable --agent codex --scope global"
    Then the file "$HOME/.codex/AGENTS.md" should be created with the AI Suite block
    And "$HOME/.codex/skills" and "$HOME/.codex/meta" should be populated

  Scenario: Codex Agent uninstalls cleanly from project and global scopes
    Given a project directory where Codex agent has been enabled
    When I run "ai-suite disable --agent codex --scope project --project <TARGET>"
    Then the AI Suite block should be removed from "AGENTS.md"
    And any legacy ".codexrules" file should have its AI Suite block removed
    And the ".codex/skills" and ".codex/meta" directories should be removed

  Scenario: Multi-agent compatibility is preserved
    Given the AI suite supports Cursor, Claude, OpenCode, Continue, Roo-Code, and Codex
    When enabling and disabling each agent in project and global scopes
    Then every agent should correctly manage its respective instruction/rules files without breaking other agents
