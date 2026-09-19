Feature: Ingestion and Enablement of the AI Review Bot Skill
  As an AI suite user and engineer
  I want to absorb the ai-review-bot skill into the core AI suite
  So that all supported agents can autonomously conduct deep, multi-persona code reviews with zero false positives

  Scenario: Structural compliance of absorbed ai-review-bot skill
    Given the ai-review-bot skill is absorbed into ".ai-suite/layer3-registry/core/ai-review-bot.md"
    When the suite validator "validate-suite.sh" validates the skill
    Then the skill frontmatter must contain "name: ai-review-bot"
    And the skill description must contain "Use when"
    And the skill must declare triggers including "ai-review-bot", "ai review", and "review code"
    And the skill body must be 600 lines or fewer
    And the skill must have an "Instructions" or "Workflow" section
    And the skill must have a "Negative Constraints" or "Safety" section with checkboxes

  Scenario: Persona and anti-false-positive review invariants
    Given the absorbed ai-review-bot skill definition
    Then it must define the 5 specialized reviewer personas:
      | Persona                  | Mandate                                            |
      | Senior Engineer          | Correctness, security, race conditions, crashes    |
      | Commit Message Reviewer  | Conventional commit prefix and 50-char limit       |
      | GitHub Workflow Reviewer | Runner pool exhaustion and sleep loop prevention   |
      | Accessibility Reviewer   | WCAG AA compliance, semantic HTML, ARIA attributes |
      | CL & File Summarizer     | Concise 3-4 sentence changeset summary             |
    And it must enforce diff direction awareness forbidding comments on removed lines
    And it must mandate that project-specific rules strictly override general standards
    And it must forbid raising defects against reference-only context files
    And it must provide concrete review examples for race conditions, secrets, and timing attacks

  Scenario: Multi-agent installation and enablement parity
    Given the ai-review-bot skill exists in ".ai-suite/layer3-registry/core/ai-review-bot.md"
    When the user runs "ai-suite enable --scope project --agent cursor"
    Then the skill must be mirrored to ".cursor/skills/ai-review-bot/SKILL.md"
    When the user runs "ai-suite enable --scope project --agent codex"
    Then the skill must be mirrored to ".codex/skills/ai-review-bot/SKILL.md"
    When the user runs "ai-suite enable --scope global --agent all"
    Then the skill must be mirrored across all enabled agent destinations
