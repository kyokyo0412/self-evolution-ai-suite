Feature: Dynamic Domain SME and Risk Profiling in TDD Team Skill
  As an autonomous engineering team
  In order to deliver domain-resilient, production-ready software across arbitrary industries
  We require the tdd-team skill to dynamically instantiate a Principal SME & Domain Architect and enforce domain failure mode test conversion

  Scenario: Dynamic Role and Team Roster Definition
    Given the tdd-team skill file ".ai-suite/layer3-registry/core/tdd-team.md"
    Then it must define an eleven-role distinguished engineering team
    And it must include "Principal Subject Matter Expert (SME) & Domain Architect (Dynamically Instantiated)" in the Team Roster
    And the SME role must list domain terminology, regulatory constraints, RFCs, failure modes, NFRs, and domain edge cases

  Scenario: Phase 1.1 Domain Classification and Risk Profiling
    Given the tdd-team skill file ".ai-suite/layer3-registry/core/tdd-team.md"
    When examining Phase 1.1 Product Discovery
    Then it must contain an explicit "Domain Classification & Risk Profiling" step
    And it must require outputting "Domain Category & Standards Mapping"
    And it must require outputting "Domain Specific Failure Modes"
    And it must require outputting "Domain Non-Functional Requirements (NFRs)"

  Scenario: Phase 1.3 and Phase 1.5 Domain Failure Mode Conversion
    Given the tdd-team skill file ".ai-suite/layer3-registry/core/tdd-team.md"
    When examining Phase 1.3 Define
    Then it must mandate converting SME domain failure modes into executable BDD Gherkin scenarios
    When examining Phase 1.5 Test Design
    Then it must mandate converting SME domain failure modes into executable SDET test plans

  Scenario: Phase 1.4 and Phase 1.6 Review Gates Rejection Rules
    Given the tdd-team skill file ".ai-suite/layer3-registry/core/tdd-team.md"
    When examining Phase 1.4 Requirement Review
    Then the Chief Reviewer must reject requirements if domain-specific compliance, safety, or protocol bounds were omitted
    When examining Phase 1.6 Test Design Review
    Then the Chief Reviewer must reject test designs if domain failure modes or compliance bounds were omitted

  Scenario: Execution Directives for SME Persona and Domain Context Matrix
    Given the tdd-team skill file ".ai-suite/layer3-registry/core/tdd-team.md"
    Then it must instruct inspecting TASK and BACKGROUND to identify the target domain
    And it must instruct instantiating the Principal SME persona before Phase 1.1 proceeds
    And it must require outputting a "Domain Context Matrix" before Gherkin feature files are generated
