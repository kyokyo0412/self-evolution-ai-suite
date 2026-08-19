Feature: Isolate AI suite project and Host agent

  Background:
    Given the AI suite is being developed by a Host agent
    And the AI suite project is located in ".ai-suite/"
    And the Host agent configuration is located in ".cursor/"

  Scenario: Absorb capability for AI suite project
    When the Augmented Agent absorbs capability from another Host Agent
    Then the capability MUST be merged into the developing AI suite source code (".ai-suite/")
    And the capability MUST be merged into the Host agent configuration (".cursor/")

  Scenario: Integrate capability for AI suite project
    When the Augmented Agent integrates capability to another Host Agent
    Then the capabilities MUST be sourced ONLY from the AI suite source code (".ai-suite/")
    And the capabilities MUST NOT be sourced from the Host agent configuration (".cursor/")

  Scenario: Pull evolution for AI suite project
    When the Augmented Agent pulls evolution from another Host Agent
    Then the evolution MUST be integrated into the AI suite being developed (".ai-suite/")
    And the Host agent configuration (".cursor/") MUST be updated with the collected evolution

  Scenario: Publish the AI suite
    When the AI suite is published as a package
    Then the package MUST NOT contain any domains ("layer3-registry/domains")
