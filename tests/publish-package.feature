Feature: Publish AI Suite as an install package

  Scenario: Publish the suite without domain knowledge
    When the user runs:
      bash ai-suite publish
    Then it creates a tarball package of the ai-suite
    And the package excludes the .ai-suite/layer3-registry/domains/ directory
    And the package includes .ai-suite/core, .ai-suite/layer1-abstraction/agents, .ai-suite/layer4-evolutionary/validation
    And the package includes ai-suite enable, ai-suite disable, ai-suite evolve, ai-suite publish
    And it exits with 0
