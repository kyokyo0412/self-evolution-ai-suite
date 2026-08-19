Feature: AI Suite Core Architecture Alignment
  As an AI Agent Developer
  I want the physical directory structure of the AI suite to strictly match the 4-tier layer model
  So that the codebase reflects the conceptual architecture defined in ai-suite_core_concept.md

  Scenario: Physical directory structure maps to the 4-Tier Layered Architecture
    Given the ai-suite is installed
    When I inspect the ".ai-suite" directory
    Then I should see exactly the following top-level directories:
      | directory              |
      | layer1-abstraction     |
      | layer2-cognitive       |
      | layer3-registry        |
      | layer4-evolutionary    |
    And the old directories "agents", "core", "domains", "meta" should not exist

  Scenario: Agent Adapters reside in the Abstraction Layer
    Given the new architecture is in place
    When I look for agent adapters
    Then I should find them under ".ai-suite/layer1-abstraction/agents/"

  Scenario: Cognitive & Memory Fabric components are correctly placed
    Given the new architecture is in place
    When I look for the memory scripts
    Then I should find "memory.sh" under ".ai-suite/layer2-cognitive/memory/"
    When I look for the Meta-Cognitive Compiler skills
    Then I should find "prompt-compiler.md" under ".ai-suite/layer2-cognitive/meta-compiler/"

  Scenario: Capability Registry holds Universal Skills, Domains, and Safety
    Given the new architecture is in place
    When I look for universal skills
    Then I should find them under ".ai-suite/layer3-registry/core/"
    When I look for production safety guardrails
    Then I should find "production-safety.md" under ".ai-suite/layer3-registry/safety/"

  Scenario: Evolutionary Engine holds Reflection, Merging, and Validation
    Given the new architecture is in place
    When I look for the reflection protocol
    Then I should find "reflection-protocol.md" under ".ai-suite/layer4-evolutionary/reflection/"
    When I look for evolutionary merging skills
    Then I should find "absorb-capability.md" under ".ai-suite/layer4-evolutionary/merging/"
    When I look for validation scripts
    Then I should find "validate-suite.sh" under ".ai-suite/layer4-evolutionary/validation/"

  Scenario: System continues to function properly
    Given the new architecture is in place
    When I run "bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh"
    Then the exit code should be 0
