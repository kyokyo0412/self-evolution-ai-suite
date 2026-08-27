Feature: Enhanced TDD Team Review, Senior Roles, Robustness, and Line-Level Code Quality
  As an AI software development engineering team
  I want the tdd-team skill to incorporate senior expert roles, deep design/architecture reviews, scalability and parallelism engineering, and rigorous line-level code reviews
  So that the AI agent consistently generates high-quality, robust, secure, and production-grade software with zero edge-case regressions

  Scenario: Senior and Expert Team Roster
    Given the tdd-team skill is defined
    Then the Team Roster must include senior and distinguished roles with deep expertise:
      | Role                                               | Expertise Scope                                                                                         |
      | Staff/Principal PM & Product Strategist            | Edge-case foresight, non-functional requirements, failure modeling, requirements disambiguation         |
      | Distinguished AI Expert & Cognitive Architect      | Prompt optimization, cognitive architecture, context management, anti-hallucination guardrails          |
      | Fellow/Principal Engineer & Chief Reviewer         | Rigorous veto power, line-by-line deep code audits, architectural sanity, 1E-class security standards    |
      | Principal Systems Architect                        | Concurrency, parallel processing, scalability, high performance, interface contracts, failure domains    |
      | Senior Principal SDET & Chaos Gatekeeper           | BVA, equivalence partitioning, fault injection, negative paths, dynamic assertions, requirement sanity  |
      | Staff Systems Developer                            | Defensive programming, deterministic execution, leak prevention, robust string/stream processing        |
      | Senior Lead Technical Writer & Knowledge Architect | System documentation, architectural rationales, operational guides, explicit notes & user warnings      |

  Scenario: Deep Architecture & Scalability Review in Phase 2
    Given the architectural validation phase begins
    When the Principal Engineer reviews the architecture and contracts
    Then the review must deeply evaluate:
      | Review Dimension     | Criteria                                                                                           |
      | Scalability & Scale  | Throughput, memory consumption bounds, horizontal/vertical scalability, streaming large datasets    |
      | Concurrency & Async  | Parallel processing capabilities, worker pools, non-blocking I/O, race condition/deadlock prevention|
      | Robustness & Failures| Failure blast radius, graceful degradation, circuit breaking, deterministic recovery, idempotency  |
      | Contract Integrity   | Strict interface schemas, error models, backward compatibility, SOLID principles                   |

  Scenario: Rigorous Line-Level Code Review in Phase 3
    Given the Developer has implemented the green code or refactored
    When the Principal Engineer performs the Code & Implementation Review
    Then the review must conduct a mandatory line-level audit across critical defect categories:
      | Category                  | Verification Checklist                                                                              |
      | Boundary Handling         | Off-by-one errors, empty/null/nil inputs, minimum/maximum value extremes, slice/index bounds        |
      | Error Handling & Safety   | No swallowed exceptions, explicit propagation, deterministic cleanup, actionable error messages    |
      | String & Stream Safety    | Safe quoting, buffer/stream bounds, UTF-8 safety, injection prevention, regex backtracking safety   |
      | Resource & Memory Safety  | Explicit resource deallocation, file descriptor closures, no memory leaks, timeout enforcement      |
      | Concurrency & Race Safety | Thread-safety, atomic operations, lock contention minimization, deadlock-free lock ordering         |
      | Algorithmic Efficiency    | Time/space complexity ($O(N)$ vs $O(N^2)$), vectorization/batching, minimal disk I/O and searches  |
      | User Prompt Alignment     | Exact fulfillment of user requirements and negative constraints without omitting any edge case     |
