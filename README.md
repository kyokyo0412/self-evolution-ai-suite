# AI Suite - Universal Self-Evolving Agent Framework

A self-improving AI framework that works with **any AI coding agent** (Cursor, Claude Code, OpenCode, VS Code Continue, VS Code Roo Code, Codex) across **any domain** (web, systems, cloud, and more).

---

## Introduction

AI Suite is a structured set of skills, templates, and meta-protocols that makes AI coding agents smarter and more consistent. After each task, the agent can **reflect and improve its own skills** - without auto-committing, so you stay in control.

```
.ai-suite/
|-- layer1-abstraction/   <- Host & Environment Interface
|   |-- _portable.sh      <- Multi-Environment portability
|   \-- agents/           <- Agent-specific configuration
|       |-- cursor/       <- Cursor IDE (.cursorrules + ~/.cursor/skills/)
|       |   |-- skills/   <- Cursor-only skills
|       |   \-- adapter.sh
|       |-- claude/       <- Claude Code
|       \-- ...
|-- layer2-cognitive/     <- The Brain (Memory & Compilation)
|   |-- memory/           <- Hierarchical Memory System (memory.sh)
|   |-- meta-compiler/    <- Meta-Cognitive prompts (prompt-compiler)
|   \-- templates/        <- Universal prompt templates
|-- layer3-registry/      <- The Muscle (Capabilities)
|   |-- core/             <- Universal skills (TDD, docs, review)
|   |-- domains/          <- Domain-specific packs (opt-in)
|   \-- safety/           <- Production safety guardrails
\-- layer4-evolutionary/  <- The DNA (Self-Improvement)
    |-- reflection/       <- Reflection protocol & evolution reports
    |-- merging/          <- Semantic capability merging (absorb, integrate)
    \-- validation/       <- Stage-gated test suites (validate-suite.sh)
```

---

## Features

- **Memory System**: Agents maintain a persistent, layered index of project context, a chronological log of tasks, an important memory for long sessions, and a timeline memory. This memory is isolated per agent and split into project-specific memory (indexes, layers, timeline, important) and global history (tasks), preventing context flushing in long sessions. The memory system is auto-initialized when the suite is installed, and can be temporarily masked or excluded during evolution. The AI suite explicitly instructs agents to review and update this memory during tasks.
- **Enhanced TDD Team, Dynamic Domain SME, Web/Mobile Architecture & AI-Augmented Workflow**: The `tdd-team` skill operates as a fully autonomous eleven-role distinguished engineering team composed of top-tier, industry-leading professionals (Principal Subject Matter Expert (SME) & Domain Architect dynamically instantiated for any target domain, Staff/Principal PM & Product Strategist, Distinguished AI Expert & Cognitive Architect, Fellow/Principal Engineer & Chief Reviewer with absolute veto authority, Senior Principal Distributed Systems Architect, Principal UX/UI Product Designer & Design Systems Architect, Principal Frontend & Mobile Solutions Architect, Principal AI-Augmented Workflow & Interaction Engineer, Senior Principal SDET / Chaos Gatekeeper, Staff Systems Developer, and Senior Staff Technical Writer & Knowledge Architect). It enforces dynamic domain expertise (Domain Classification & Risk Profiling, Domain Context Matrix, industry RFC/compliance mapping, domain-specific failure mode test conversion), modern UI/UX design systems (color palette, typography hierarchy, 4px/8px spacing grids, 44px+ mobile touch targets, WCAG AA/AAA accessibility), dumb presentation components with custom hook logic isolation, AI-augmented workflow patterns (token streaming, optimistic UI updates, generative skeleton loaders, fallback recovery), deep architectural reviews (scalability, concurrency, parallel processing, failure blast radius, graceful degradation, domain regulatory conformance), and mandatory multi-dimensional line-level code reviews (boundary & off-by-one handling, deterministic error handling, string/stream injection safety, resource/memory safety, concurrency/race safety, algorithmic complexity, domain integrity & regulatory safety, prompt alignment).
- **Enhanced Early Product Design**: The TDD process includes a robust Phase 1 that explicitly mandates simulated PM discussion to debate tradeoffs and multiple iterations to thoroughly review legacy features before generating executable specifications.
- **Multi-Agent Support**: Works seamlessly with Cursor, Claude Code, OpenCode, VS Code Continue, Roo Code, and Codex.
- **Proactive Resolution & Never-Give-Up Spirit**: AI Suite Agents operate in a continuous loop of proactive execution. If an issue is encountered, they autonomously explore alternative approaches, analyze, and iterate until the problem is solved. When explicitly instructed not to give up, they will persist--exhausting all possible solutions--while strictly adhering to the prohibition against damaging the production environment. Otherwise, it should run as normal mode.
- **Auto-Evolution**: AI Suite Agents are now equipped with an Auto-Evolution Directive, meaning they will automatically trigger the Reflection Protocol at the end of any complex or multi-attempt task without requiring user prompting.
- **Self-Evolution**: Agents reflect on their performance and generate new skills or improve existing ones autonomously. Evolutions are strictly driven by deep semantic understanding to continuously improve agent effectiveness and end-user usability.
- **Universal Workflow**: Unified interface (`ai_suite_workflow.sh`) for evolution, capability absorption, and external integration.
- **Remote Deployment**: Install, manage, and evolve the suite on remote SSH hosts.
- **Domain Registry**: Share and install specialized AI skills across teams instantly using a lightweight Git-backed registry.
- **Smart 3-Way Merge**: Intelligently merge remote evolutions back to your local repository without silently overwriting data.
- **Production Safety & General Directives**: Built-in guardrails to prevent destructive actions on production environments, and universal directives that enforce strict negative constraints against autonomous `git commit` execution and temporary file pollution, concise task summaries (which follow normal skill reports), support for executing multiple skills together without skipping steps, and mandatory verification of all tasks.
- **1E-Class Nuclear Safety Standards**: Built-in code quality and testing standards specifically designed for 1E-class safety systems (e.g., Nuclear Reactor Protection Systems), enforcing deterministic execution, formal verification, MC/DC coverage, and strict traceability.
- **Efficiency & Quality**: Core skills enforce parallel tool execution for faster performance and mandatory linter/quality checks to ensure high product development quality.

---

## Installation

### Enable for Cursor IDE (project scope)

```bash
./ai-suite enable --agent cursor --scope project
```

### Enable for Claude Code (project scope)

```bash
./ai-suite enable --agent claude --scope project
```

### Enable for both agents at once

```bash
./ai-suite enable --agent all --scope project
```

### Enable globally (all projects on this machine)

```bash
./ai-suite enable --agent cursor --scope global
```

### Add other agents

```bash
./ai-suite enable --agent opencode --scope project
./ai-suite enable --agent continue --scope project
./ai-suite enable --agent roo-code --scope project
./ai-suite enable --agent codex --scope project
```

For Codex, `ai-suite enable --agent codex` (or `--scope global`) writes full directives, code-quality standards, nuclear safety, production safety guardrails, and memory hooks into `AGENTS.md`, and mirrors all framework skills, meta-protocols, templates/prompts, scripts, rules, and directives into `.codex/` (or `~/.codex/`). When installed from a published package, all proprietary vendor domains are guaranteed to be 100% absent.

### Remote install

```bash
# Install all skills on a remote host
./ai-suite enable --scope remote \
  --host "user@hostname" \
  --agent cursor
```

### Disable

```bash
./ai-suite disable --agent cursor --scope project
./ai-suite disable --agent claude --scope project
./ai-suite disable --agent all   --scope global
```

### Preview without making changes

```bash
./ai-suite enable --agent all --scope project --dry-run
```

---

## How to Use by AI Prompt

You can interact with the AI Suite entirely through natural language prompts. The suite provides specialized skills that listen for specific triggers.

### Remote Management
Use the **`remote-suite`** skill to manage ai-suite on remote SSH hosts using plain English.
- `install ai-suite on user@hostname`
- `install ai-suite on user@hostname for claude`
- `install ai-suite on user@hostname project /opt/myapp`
- `check ai-suite status on user@hostname`
- `remove ai-suite from user@hostname`
- `preview install ai-suite on user@hostname`

### Workflow Orchestration
Use the **`evolve-collect`**, **`absorb-capability`**, **`integrate-capability`**, and **`loop-work`** skills to manage capabilities and iterative execution:
- `loop-work 3 times to use tdd-team skill to build a calculator`
- `collect evolution from user@hostname`
- `push the evolved suite to user@hostname`
- `sync reflection from user@host1 and user@host2`
- `absorb capability from user@hostname`
- `ingest external agent`
- `integrate ai suite to user@hostname`
- `push capability to external agent`

### Reflection
After any task, trigger self-improvement:
- **Any agent:** type `Run Reflection`
- **Verbose:** `Reflect on the last task` or `Improve the suite`

---

## Command Line Usage

The AI Suite provides a comprehensive set of shell scripts for managing the framework.

### Universal Workflow (`ai-suite`)
The `ai-suite` CLI provides a unified interface for the core ai-suite lifecycle.

- **Enable**: Enable the AI suite for a specific agent.
  ```bash
  ./ai-suite enable --agent cursor --scope project
  ```
- **Disable**: Disable the AI suite for a specific agent.
  ```bash
  ./ai-suite disable --agent cursor --scope project
  ```
- **Evolve**: Trigger reflection and collect local evolutions.
  ```bash
  ./ai-suite workflow evolve
  ```
- **Absorb**: Get instructions to prompt your AI agent to fetch capabilities from an external agent and merge locally.
  ```bash
  ./ai-suite workflow absorb --host user@remote --remote-path /path/to/project
  ./ai-suite workflow absorb --local-path /path/to/other/project
  ```
- **Integrate**: Get instructions to prompt your AI agent to push local capabilities to an external agent.
  ```bash
  ./ai-suite workflow integrate --host user@remote --remote-path /path/to/project
  ```
- **Publish**: Package the AI suite for distribution.
  ```bash
  ./ai-suite publish
  ```
- **Develop**: Guide AI Suite Development and show isolation instructions.
  ```bash
  ./ai-suite workflow develop
  ```

### Memory System (`memory.sh`)
Agents automatically use the memory system via instructions injected into `.cursorrules` or `CLAUDE.md`. You can also manually manage the memory system by sourcing the bash APIs:
```bash
source .ai-suite/layer2-cognitive/memory/core.sh
source .ai-suite/layer2-cognitive/memory/memory.sh

# Initialize memory for an agent
ai_memory_init "cursor"

# Save/Append/Load important memory
ai_memory_save_important "cursor" "Always check production safety"
ai_memory_append_important "cursor" "Added a new safety constraint"

# Save/Load layered memory
ai_memory_save_layer "cursor" "architecture" "System is microservices"

# Append to timeline memory
ai_memory_append_timeline "cursor" "Started the task"

# Save/Load index memory
ai_memory_save_index "cursor" "high-level" "Project overview..."
content=$(ai_memory_load_index "cursor" "high-level")

# Save/Load/List tasks
ai_memory_save_task "cursor" "task-1" "Task details..."
ai_memory_list_tasks "cursor"
ai_memory_load_task "cursor" "2026-06-26_12-00-00_task-1.md"

# Mask or Clean memory
ai_memory_mask "cursor" "on"   # temporarily hide memory from agents
ai_memory_clean "cursor"       # delete all memory
```

### Remote Evolution (`ai-suite evolve`)
Collect remote ai-suite evolutions into the local git repo, and push the updated suite back.
```bash
./ai-suite evolve collect --host user@hostname
./ai-suite evolve push --host user@hostname
```

### Domain Management (`ai-suite manage`)
Fetch domain skills from a remote git repository using sparse-checkout.
```bash
./ai-suite manage domain install https://github.com/org/ai-skills.git --domain linux
```

### Package Distribution (`ai-suite publish`)
Package the ai-suite for distribution, excluding vendor-specific domain knowledge.
```bash
./ai-suite publish
```

---

## Skills

### Core Skills (agent-agnostic, domain-agnostic)

| Skill | Trigger phrase |
|---|---|
| `feature-doc` | "feature_doc", "document feature" |
| `question-doc`| "question_doc", "answer question", "explain codebase" |
| `tdd-team` | "use TDD", "Red-Green-Refactor", "Gherkin" |
| `autonomous-team` | "act as a team", "end-to-end delivery" |
| `codebase-deepdoc` | "deep doc", "full architectural documentation" |
| `ai-review-fix` | provide a code-review URL + "fix comments" |
| `evolve-collect` | "collect evolution from", "sync reflection" |
| `remote-suite` | "install ai-suite on", "check ai-suite status on", "remove ai-suite from", "deploy ai-suite to" |
| `absorb-capability` | "absorb capability", "absorb agent", "ingest external agent" |
| `integrate-capability` | "integrate ai suite", "push capability", "merge to external agent" |
| `deep-code-audit` | "deep code audit", "code quality audit", "architecture audit" |
| `prompt-compiler` | "compile prompt", "meta-cognitive", "AI Expert", "optimize prompt", "Prompt Architect" |

### Cursor-Specific Skills

| Skill | Trigger phrase |
|---|---|
| `ai-suite-architect` | "design a Cursor skill", "harden a prompt", "generate .cursorrules" |
| `prompt-developer` | "design a prompt", "improve this rule" |

---

## Dynamic Domain SME Operational Runbook & Developer Guide

The `tdd-team` skill integrates a dynamically instantiated **Principal Subject Matter Expert (SME) & Domain Architect** into an autonomous eleven-role distinguished engineering team. This runbook provides complete operational guidance, architectural workflows, multi-domain reference matrices, and verification recipes for developers and AI agents.

### Domain Profiling & SME Lifecycle Workflow

When `tdd-team` is invoked, the AI agent must strictly follow the stage-gated lifecycle:

```
[TASK] + [BACKGROUND]
        |
        v (Immediate Domain Identification)
[Principal SME & Domain Architect Instantiated]
        |
        v (Phase 1.1 Domain Classification & Risk Profiling)
[Domain Context Matrix Emitted in Chat]
        |
        +---> Standards & Regulatory Mapping (RFCs, ISO, HIPAA, PCI-DSS)
        +---> Domain-Specific Failure Modes (Race conditions, packet loss, entity leaks)
        +---> Domain Non-Functional Requirements (Latency SLAs, payload bounds)
        |
        v (Review Gate 1.4 / 1.6 Veto Authority)
[BDD Gherkin & SDET Test Translation] (Failure modes converted into executable tests)
        |
        v (Phase 2 & Phase 3 Concurrency & 1E-Class Safety)
[Architecture & Implementation] (Distributed locks, idempotency, deterministic bounds)
        |
        v (Phase 4 Chaos Injection Gate)
[Adversarial Testing] (Network partitions, malformed frames, clock jitter, mid-tx expirations)
        |
        v (Phase 5 Project Closure)
[Domain Compliance & Regulatory Traceability Matrix Delivered]
```

### Multi-Domain Recipe Matrix

| Domain | Standards & Regulations | Critical Failure Modes | Target NFRs & Latency SLAs |
|---|---|---|---|
| **FinTech & HFT** | PCI-DSS 4.0, SOC2 Type II, FIX 5.0, FAST | Order book race conditions, double-spend, floating-point drift | P99 latency < 1ms, zero precision loss, atomic idempotency |
| **Telecom** | RFC 3261 (SIP), RFC 3550 (RTP), 3GPP 5G-NR | Packet drop, out-of-order SIP INVITE, jitter buffer underrun | Media latency < 20ms, jitter < 5ms, 99.999% availability |
| **HealthTech** | HIPAA Security Rule, HITECH, HL7 v2, FHIR | PHI leaks in error logs/telemetry, unencrypted resting payload | Strict access audit logging, zero PHI leakage, TLS 1.3 |
| **Aerospace & Defense** | DO-178C DAL-A, ARINC 429, ARINC 653 | Task scheduling overrun, avionics bus collision, bit flips | Deterministic execution time, zero dynamic allocations, formal proof |
| **IoT & Telemetry** | MQTT 5.0, CoAP (RFC 7252), TLS 1.3 | Broker disconnect during QOS-2, clock drift, flash wear | Payload bound < 512B, sub-50ms processing, power-loss safety |
| **Automotive** | ISO 26262 ASIL-D, UNECE R155/R156, AUTOSAR | CAN frame collisions, priority inversion, ECU spoofing | Hard real-time cycle < 10ms, tamper-proof audit log, memory bounds |

### Translating Domain Failure Modes to Executable Tests

In Phase 1.3 (Define) and Phase 1.5 (Test Design), the SDET and BDD specifications must directly convert every failure mode identified by the Dynamic SME into executable test scenarios:

1. **Network Partitions**: Verify circuit breaker tripping, backoff retries, and offline queueing.
2. **Expired Tokens Mid-Transaction**: Verify transaction rollback, token refreshing, and idempotent resumption.
3. **Concurrent Order Checkouts**: Verify distributed lock leases, idempotency tokens, and optimistic concurrency versioning.
4. **Sensitive Entity Redaction**: Verify automated masking of PHI/PII/cardholder data in debug logs and telemetry streams.

```gherkin
Scenario: Prevent double-spend during concurrent order processing
  Given two concurrent checkout requests arrive with the same idempotency token
  When the distributed transaction manager acquires the distributed lock lease
  Then the first transaction successfully reserves inventory and charges payment
  And the second transaction is safely deduplicated and returns the cached receipt
```

### Domain Chaos Injection & Adversarial Chaos Testing Runbook

In Phase 4 (End-to-End System QA Gate), tests must subject the system to active adversarial conditions:

- **Network Partition Simulation**: Simulate split-brain and severed socket connections to confirm cluster failover without split state.
- **Malformed Protocol Frame Injection**: Fuzz input endpoints with corrupted byte streams and out-of-spec packet payloads to verify deterministic rejection.
- **Clock Jitter & Skew**: Introduce artificial time dilation and leap second events to test TTL algorithms and lease expirations.
- **Mid-Transaction Token Expiration**: Terminate authorization credentials during payload ingestion to guarantee atomic rollback without orphan resources.

### 1E-Class Safety & Deterministic Resource Runbook

In Phase 3.5, the Fellow/Principal Engineer executes line-level code reviews strictly auditing 1E-Class Safety standards:

- **Zero Dynamic Allocations**: Hot paths and real-time processing loops must utilize pre-allocated static ring buffers.
- **Deterministic Execution Time**: Ensure all loops and recursions have hard-coded max iteration caps; no unbounded while-loops.
- **Resource Deallocation & Leak Prevention**: Audit every file descriptor, socket handle, and database transaction for explicit `defer` / `finally` release.
- **Defensive Boundary Bounding**: Enforce explicit string truncation, payload length checks, and slice bounds checks before memory copy.

### Domain Compliance & Regulatory Traceability Matrix

In Phase 5 (Project Closure), the Technical Writer produces a comprehensive compliance traceability matrix mapping:
- Requirement ID and User Story
- Target Industry Regulatory Rule or RFC (e.g., PCI-DSS Section 3.4, HIPAA 164.312)
- SME-Identified Domain Failure Mode
- Executable Test File and Assertion Method
- Terminal Verification Result (PASS / MC-DC proof)

---

## Flag Reference

### `ai-suite enable`

| Flag | Values | Default | Description |
|---|---|---|---|
| `--agent` | `cursor` \| `claude` \| `opencode` \| `continue` \| `roo-code` \| `codex` \| `all` | `cursor` | Target agent(s) |
| `--scope` | `project` \| `global` \| `remote` | `project` | Install scope |
| `--project PATH` | directory | script dir | Override project root |
| `--host USER@HOST` | SSH target | - | Remote host (scope=remote) |
| `--remote-path PATH` | remote dir | `$HOME/.ai-suite-deploy` | Remote install dir |
| `--remote-scope` | `project` \| `global` | `global` | Scope on the remote |
| `--dry-run` | - | off | Preview only, no changes |
| `--verify` | - | off | Run validate-suite.sh and exit |
| `--install-hook` | - | off | Install auto-enable shell hook |
| `--shell` | `auto` \| `zsh` \| `bash` \| `both` | `auto` | Shell(s) for hook |
| `--uninstall` | - | off | Delegate to ai-suite disable |

### `ai-suite disable`

Same flags as enable except `--verify`, `--install-hook` are replaced by `--uninstall-hook`.

### `ai-suite evolve`

```
./ai-suite evolve collect --host USER@HOST [--host ...] [--remote-path PATH] [--dry-run]
./ai-suite evolve push    --host USER@HOST [--host ...] [--remote-path PATH]
                         [--remote-scope global|project] [--dry-run]
```

---

## Auto-Enable Hook

Install a shell hook so the suite activates automatically whenever you `cd` into a git repo:

```bash
./ai-suite enable --install-hook
./ai-suite enable --install-hook --shell zsh    # or bash / both
```

Remove the hook:

```bash
./ai-suite disable --uninstall-hook
```

---

## Validation

Lint all skill files across all tiers to ensure they meet syntax and semantic quality standards (frontmatter, triggers, instructions, and safety constraints):

```bash
bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh
```

---

## Test Suite

```bash
# Full test matrix (313 checks)
bash .ai-suite/layer4-evolutionary/validation/run-acceptance-tests.sh      # enable/disable lifecycle (68)
bash tests/test-refactor-contracts.sh  # structure contracts (55)
bash tests/test-refactor-eut.sh        # multi-agent EUT (43)
bash tests/test-evolve-contracts.sh    # ai-suite evolve contracts (16)
bash tests/test-evolve-eut.sh          # ai-suite evolve EUT (18)
bash tests/test-evolve-collect-contracts.sh  # evolve-collect skill (22)
bash tests/test-evolve-collect-eut.sh        # evolve-collect EUT (33)
```

---

## Git Commands

On first setup:

```bash
chmod +x ai-suite .ai-suite/cli/*.sh
git init
git add .
git commit -m "feat: bootstrap ai-suite universal agent framework"
```

---

## Adding a New Skill

1. Create `.ai-suite/layer3-registry/core/skills/my-skill.md` (universal) or `.ai-suite/layer1-abstraction/agents/cursor/skills/my-skill.md` (Cursor-specific) or `.ai-suite/layer3-registry/domains/<domain>/skills/my-skill.md` (domain-specific)
2. Add YAML frontmatter:

```yaml
---
name: my-skill
description: <one sentence starting with a verb>. Use when <trigger condition>.
triggers:
  - keyword phrase 1
  - keyword phrase 2
---
```

3. Validate: `bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh`
4. For Cursor: `./ai-suite enable --agent cursor --scope global` to deploy
5. For Claude: `./ai-suite enable --agent claude --scope project` to regenerate `CLAUDE.md`

---

## Production Safety

The file `.ai-suite/layer3-registry/safety/production-safety.md` is deployed as an `alwaysApply: true` Cursor rule (for Cursor), or embedded in `CLAUDE.md` (for Claude). It enforces:

- No `rm -rf` on production-looking paths
- No `git push --force` to main/master
- No deployment to targets containing identifiers like `prod`

---

## Architecture

The AI suite is designed with the following core concepts:

- **AI suite**: The tool being developed.
- **Host Agent**: An agent that is developing the AI suite.
- **Augmented Agent**: A Host agent with the AI suite enabled.
- **AI suite project**: The AI suite tool which is being developed by an Augmented Agent.
- **AI suite enable/disable**: Install/Uninstall the AI suite to a Host Agent.
- **Augmented Agent pull/push evolution**: An Augmented Agent can push/pull evolution from/to another Host Agent.
- **Augmented Agent pull evolution for AI suite project**: The evolution is not only pulled from another Host Agent to the Augmented Agent, but the evolution also will be integrated into the AI suite being developed. The user can review and submit the evolution as a new improved AI suite to the git repo manually.
- **Augmented Agent absorb/integrate capability**: An Augmented Agent can absorb/integrate the capability from/to another Host Agent.
- **Augmented Agent absorb capability for AI suite project**: An Augmented Agent can absorb the capability from another Host Agent, but the capability also will be integrated into the AI suite being developed. The user can review and submit the evolution as a new improved AI suite to the git repo manually.
- **Publish**: The AI suite can publish itself as a package by CLI without any domains (to avoid copyright issues). The Augmented Agent of an AI suite project can also publish a package by prompt or CLI without any domains.

### Key Workflows

1. **Absorb**: The AI suite Agent can absorb capabilities from any external Agent. The capability is absorbed into the AI suite Agent, forming a new capability.
2. **Integrate**: The AI suite Agent can integrate its capabilities into any external Agent. The external Agent will then have the capabilities of the AI suite Agent, transforming it into a new AI suite Agent.
3. **Publish**: The AI suite Agent can publish its capabilities into an AI suite publish package, which can be distributed to other agents.

### 4-Tier Layered Architecture

The AI-Suite employs a **4-Tier Layered Architecture**, which maps directly to its physical directory structure:

| Layer | Path | Purpose |
|---|---|---|
| **Layer 1: Abstraction** | `layer1-abstraction/` | Host Agent interfaces, universal adapters (`adapter.sh`), multi-environment wrappers (`_portable.sh`), and agent-specific skills (`agents/cursor/skills/`). |
| **Layer 2: Cognitive** | `layer2-cognitive/` | The Brain. Contains the Hierarchical Memory System (`memory/`) and Meta-Cognitive Compiler prompts/templates (`meta-compiler/`, `templates/`). |
| **Layer 3: Registry** | `layer3-registry/` | The Muscle. Houses universal skills (`core/`), proprietary domain packs (`domains/`), production safety guardrails (`safety/`), and general agent directives (`directives/`). |
| **Layer 4: Evolutionary** | `layer4-evolutionary/` | The DNA. Drives self-improvement via `reflection/`, stage-gated `validation/`, and capability `merging/` (absorb, integrate, evolve-collect). |
| Toggle scripts | `{enable,disable,evolve}_suite.sh` | User-facing CLI located at the project root |

## AI Suite Development Isolation

When developing the AI suite itself, it is crucial to isolate the source code repository from the runtime configuration of the Augmented Agent.

1.  **Do not use `--scope project` inside the AI suite source repository.** This will mix runtime configurations (like `.cursorrules` and `.cursor/skills`) with the source code.
2.  **Use `--scope global`** to install the AI suite globally on your machine for development purposes.
3.  If you accidentally contaminate the source repository, use the `scripts/clean_dev_env.sh` script to remove the runtime configurations.
4.  To collect evolutions (e.g., new skills) that you have developed locally in your global installation back into the source repository, use the `--local` flag with the collect command:
    ```bash
    ./ai-suite evolve collect --local
    ```
