# Principal Coding Engineer & Adversarial AI-Review Contracts

Specifies structural contracts and behavioral requirements for embedding a dedicated **Principal Coding Engineer (PCE) & Chief Reviewer Adversarial Review & Pre-Emptive Fix Gate** into the `tdd-team` skill (`.ai-suite/layer3-registry/core/tdd-team.md`, `~/.cursor/skills/tdd-team/SKILL.md`, and `~/.codex/skills/tdd-team/SKILL.md`) and supporting directives (`code-quality.md`, `agent-directives.md`).

## 1. Roster Contract
- The `Team Roster` in `tdd-team.md` must explicitly feature the **Fellow/Principal Coding Engineer & Chief Reviewer (Veto Authority & Remediation Master)**.
- The role must explicitly specify veto authority, adversarial AI-review simulation capability, autonomous remediation authority, and enforcement of the 10-Dimension Anti-AI-Review Verification Checklist.

## 2. Phase 3 Protocol Contract: Adversarial AI-Review & Pre-Emptive Fix Gate
Phase 3 of `tdd-team.md` must incorporate:
1. **Phase 3.5: Principal Coding Engineer Adversarial AI-Review & Pre-Emptive Fix Loop**:
   - Explicit execution of an Adversarial AI-Review Simulation mimicking external tools (SonarQube, CodeQL, Bugbot, Gerrit AI Reviewers).
   - Structured 10-dimension audit:
     1. Boundary & Null/Nil Safety (null pointer checks, slice boundaries, off-by-one).
     2. Deterministic Error Handling & Propagation (no swallowed errors, explicit propagation, no bare excepts).
     3. Strict Resource Lifecycle & Leak Prevention (`defer`, `with`, `finally`, `trap`, zero unclosed descriptors/sockets/processes).
     4. Concurrency, Race Safety & Thread Synchronization (atomic operations, lock contention, race detection, TOCTOU safety).
     5. Security, Injection & Sanitization (strict shell quoting `"$var"`, path traversal checks, injection prevention).
     6. Algorithmic Efficiency & Bounded Complexity ($O(N)$ vs $O(N^2)$, bounded loops, deterministic execution).
     7. Code Formatting & Cleanliness Standards (zero space/tab-only empty lines, functions <= 50 lines, selective formatting only on modified lines).
     8. 1E-Class Nuclear Safety & Failure Domain Containment.
     9. Anti-Hardcoding Rigor & Dynamic Test Assertions (counts computed dynamically at runtime).
     10. Domain RFC/Protocol Conformance & User Prompt Alignment.
2. **Phase 3.6: Autonomous Pre-Emptive Fix & Remediation**:
   - If ANY issue or smell is detected, Developer and Principal Coding Engineer MUST immediately patch the code.
   - Re-execute unit and contract tests to confirm green.
   - Issue formal **Zero-Defect Audit Certification** before stage exit.

## 3. Negative Constraints Contract
- Must contain an explicit negative constraint forbidding stage exit from Phase 3 or Phase 4 without completing the Principal Coding Engineer Adversarial Review & Pre-Emptive Fix Loop.
- Must forbid delivering code with unhandled nil/null checks, swallowed errors, unclosed resources, or space/tab-only empty lines.

## 4. Multi-Agent Synchronization Invariant
- All structural contracts and enhancements in `.ai-suite/layer3-registry/core/tdd-team.md` must be mirrored synchronously across `~/.cursor/skills/tdd-team/SKILL.md` and `~/.codex/skills/tdd-team/SKILL.md`.
