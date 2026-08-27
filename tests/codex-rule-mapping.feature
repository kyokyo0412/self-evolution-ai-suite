Feature: Codex Rule-to-Prompt Mapping and Clean Markdown Transformation
  As an AI Suite engineer
  I want all rules and directives to be formatted as clean, structured Markdown prompt sections in AGENTS.md
  And I want all mirrored rule files in .codex/rules/ to be clean Markdown (.md) without raw MDC frontmatter
  So that the Codex agent parses and executes all directives, quality standards, and safety guardrails accurately

  Scenario: Rules inlined into AGENTS.md are formatted as clean prompt instructions without YAML frontmatter
    Given the AI Suite is enabled for Codex
    When "AGENTS.md" is generated
    Then "AGENTS.md" must contain all directives, code quality standards, nuclear safety standards, and safety guardrails
    And "AGENTS.md" must NOT contain raw YAML frontmatter markers ("---", "globs:", "alwaysApply:") inside rule bodies

  Scenario: Mirrored rules in .codex/rules are clean Markdown files (.md)
    Given the AI Suite is enabled for Codex
    When rules are mirrored to ".codex/rules"
    Then all rule files must have the ".md" extension
    And no rule file in ".codex/rules" should contain raw MDC frontmatter metadata
    And ".codex/rules" must include directives, safety rules, and general rules

  Scenario: Multi-agent prompt generation preserves clean formatting
    Given the AI Suite is enabled for any Markdown-based agent (Codex, Claude, OpenCode, Continue, Roo-Code)
    When the instructions file is generated
    Then all rules must be cleanly inlined without unparsed IDE frontmatter
