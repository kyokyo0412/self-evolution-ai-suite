# TDD Team Dynamic Domain SME & Architecture Contracts

## Purpose
Specifies structural contracts and behavioral requirements for embedding dynamic domain expertise and deep domain knowledge into the `tdd-team` skill (`.ai-suite/layer3-registry/core/tdd-team.md`, `~/.cursor/skills/tdd-team/SKILL.md`, and `~/.codex/skills/tdd-team/SKILL.md`).

## Mandatory Roster Contract
1. **Principal Subject Matter Expert (SME) & Domain Architect (Dynamically Instantiated)**:
   - Adaptive persona assuming world-class expert capabilities in the target domain (e.g., Telecom, Game Engine, HealthTech, High-Frequency Trading, Aerospace, FinTech, IoT, Embedded Systems, Real-time Audio).
   - Responsibilities: Identifies domain-specific terminology, regulatory constraints (GDPR, HIPAA, PCI-DSS, ISO), industry protocols/RFCs, failure modes, non-functional requirements (NFRs), and domain-specific edge cases.
2. Team size upgraded from a ten-role distinguished engineering team to an eleven-role distinguished engineering team.

## Mandatory Stage-Gated Workflow Contracts
1. **Phase 1.1 (Product Discovery & Domain Profiling)**:
   - Must include an explicit step: `Domain Classification & Risk Profiling`.
   - The Dynamic SME must analyze `[TASK]` and `[BACKGROUND]` to explicitly output:
     - Domain Category & Standards Mapping (e.g., standard RFCs, compliance frameworks, industry best practices).
     - Domain Specific Failure Modes (e.g., race conditions in inventory, packet loss in telemetry, HIPAA PHI leakage in logging).
     - Domain Non-Functional Requirements (NFRs) (latency limits, safety margins, payload bounds).
2. **Phase 1.3 (Define)**:
   - Mandate that BDD Gherkin specs explicitly convert the SME's domain failure modes into executable test scenarios (e.g., given a network partition, given an expired token, given a concurrent checkout).
3. **Phase 1.4 (Plan & Requirement Review Gate)**:
   - Reviewer gate MUST reject requirements if the Dynamic SME determines that domain-specific compliance, safety, or protocol bounds were omitted.
4. **Phase 1.5 (Test Design & Requirement Validation)**:
   - Mandate that SDET test plans explicitly convert the SME's domain failure modes into executable test scenarios.
5. **Phase 1.6 (Test Design Review Gate)**:
   - Reviewer gate MUST reject test design if the Dynamic SME determines that domain failure modes, protocol bounds, or safety bounds were omitted.

## Mandatory Execution Instructions Contract
When execution triggers the `tdd-team` skill:
1. Immediately inspect `[TASK]` and `[BACKGROUND]` to identify the target domain.
2. Instantiate the "Principal SME & Domain Architect" persona tailored to that domain BEFORE Phase 1.1 proceeds.
3. Require the SME persona to output a "Domain Context Matrix" (Standards, Security Bounds, Latency SLAs, Edge Cases) in the chat before Gherkin feature files are generated.
