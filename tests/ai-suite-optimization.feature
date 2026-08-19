Feature: AI Suite Further Optimizations
  As an AI-Expert
  I want to optimize additional core skills in the AI Suite
  So that they execute faster and with higher quality

  Scenario: Feature-doc skill includes efficiency directives
    Given the AI suite core registry
    When I examine ".ai-suite/layer3-registry/core/feature-doc.md"
    Then the skill should contain instructions for "parallel tool calls"

  Scenario: Codebase-deepdoc skill includes efficiency directives
    Given the AI suite core registry
    When I examine ".ai-suite/layer3-registry/core/codebase-deepdoc.md"
    Then the skill should contain instructions for "parallel tool calls"
