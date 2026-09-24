Feature: AI Suite Context Optimization and Token Reduction
  As an AI Expert and AI Agent Architect
  I want all skills, directives, and rules in the AI Suite to be streamlined and compact
  So that LLM context consumption is drastically reduced without compromising functional quality or safety standards

  Background:
    Given the AI suite registry containing skills, directives, rules, and cognitive templates
    And all skills adhere to frontmatter, workflow, and negative constraints specifications

  Scenario: Streamlining registry directives to reduce LLM context token consumption
    When all directives in ".ai-suite/layer3-registry/directives" are audited and compressed
    Then each directive must retain its top-level title, core requirements, and negative constraints
    And all critical keywords ("gofmt", "clang-format", "gitreview", "clean empty lines", "temporary files") must be preserved
    And total word count across directives must be reduced while zero functional rules are dropped

  Scenario: Streamlining registry safety rules and cursor rules
    When all safety rules in ".ai-suite/layer3-registry/safety" and ".ai-suite/layer1-abstraction/agents/cursor/rules" are compressed
    Then production safety rules must retain all refuse-by-default patterns and negative constraints
    And interactive workflow rules must maintain exact state transitions and hard blocks
    And trailing whitespace on empty lines must be zero to eliminate gitreview red flags

  Scenario: Pruning redundant prose and verbosity in core and agent skills
    When all core skills in ".ai-suite/layer3-registry/core" and cursor skills in ".ai-suite/layer1-abstraction/agents/cursor/skills" are reviewed
    Then frontmatter metadata "name", "description" (with "Use when"), and "triggers" must be strictly preserved
    And frontmatter descriptions must be concise and avoid consuming unnecessary LLM catalog context
    And body line counts must remain well below 600 lines
    And instructions/workflow sections and safety/negative constraints sections must remain intact

  Scenario: Preserving full suite functionality and high test coverage
    When all test suites and contract gates are executed
    Then all contract tests must pass with 100% success rate
    And the suite validator "validate-suite.sh" must report 0 failures
    And no framework function or agent adapter must be broken
