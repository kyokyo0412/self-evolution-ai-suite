Feature: Zero-Defect Code Generation via Design-by-Contract and Strict Verification
  As an autonomous software engineering team in the AI suite
  I want the tdd-team skill to enforce Design-by-Contract, strict compilation gates, and non-vacuous assertions
  So that code generated across all languages is mathematically deterministic and provably free of defects

  Background:
    Given the AI suite provides the stage-gated tdd-team skill
    And the team operates autonomously across eleven distinguished roles

  Scenario: Design-by-Contract and Strict Compilation Directives
    Given the tdd-team skill definition file
    When the Core Directives and Negative Constraints are inspected
    Then the skill must enforce Core Directive 13 for Zero-Defect Code Generation and Formal Invariants
    And it must require Design by Contract with preconditions, postconditions, and class invariants
    And it must require zero compiler warnings under strict flags like -Wall -Werror, mypy strict, and tsc strict
    And it must enforce Core Directive 14 for Non-Vacuous Assertions and Mutation Resistance
    And the Negative Constraints must forbid code generation without DbC invariants
    And the Negative Constraints must forbid vacuous test assertions and compiler warnings

  Scenario: Formal Boundary Analysis and Dimension 9 Architecture Review
    Given the stage-gated execution protocol in Phases 1 and 2
    When requirements and architectures are formulated
    Then Phase 1.3 and 1.5 must mandate a Formal Boundary Value Analysis Extrema Matrix
    And the matrix must enumerate boundary partitions including min, max, overflow, null, and empty
    And Phase 2.1 must formulate explicit Design-by-Contract interface specifications
    And Phase 2.2 must review architectures against Dimension 9 for Formal Invariants and DbC
    And the Reviewer Gate must reject architectures lacking explicit DbC invariants

  Scenario: Strict Implementation Gates and 14-Dimension Verification Checklist
    Given Phase 3 TDD Implementation Loop
    When code and test suites are developed and audited
    Then Phase 3.1 must mandate Non-Vacuous Assertion Verification proving test failure on logic mutation
    And Phase 3.2 must enforce the Strict Compiler and Static Analysis Gate before test execution
    And Phase 3.2 must require production code to strictly satisfy DbC contracts
    And Phase 3.5 must evaluate code against the 14-Dimension Anti-AI-Review Zero-Defect Verification Checklist
    And Phase 3.6 must mandate Zero-Defect Audit Certification across all 14 checklist dimensions before stage exit
