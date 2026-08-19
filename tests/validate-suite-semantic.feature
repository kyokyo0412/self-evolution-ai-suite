Feature: Semantic Validation of AI Suite Skills
  As the AI Suite
  I want to validate the semantic content of skill files
  So that every evolution results in a positive, effective, and safe skill

  Scenario: A skill missing the triggers list in frontmatter is rejected
    Given a skill file "missing-triggers.md"
    When the skill has no "triggers:" list in the frontmatter
    Then validate-suite.sh should reject the file with a "missing 'triggers:'" error

  Scenario: A skill missing a negative constraints section is rejected
    Given a skill file "missing-constraints.md"
    When the skill body lacks a negative constraints or safety rules section
    Then validate-suite.sh should reject the file with a "missing Negative Constraints or Safety section" error

  Scenario: A skill missing an instructions section is rejected
    Given a skill file "missing-instructions.md"
    When the skill body lacks an instructions, workflow, or role section
    Then validate-suite.sh should reject the file with a "missing Instructions or Workflow section" error

  Scenario: A well-formed skill with all semantic sections is accepted
    Given a skill file "perfect-skill.md"
    When the skill has triggers, negative constraints, and instructions
    Then validate-suite.sh should accept the file and exit 0
