---
name: sdk
description: Guide users building apps, scripts, and CI pipelines with the Cursor SDK (@cursor/sdk or cursor-sdk). Use when integrating, configuring, or running Cursor agents programmatically.
triggers:
  - sdk
---
# Cursor SDK

Guides programmatic execution of Cursor agents using TypeScript (`@cursor/sdk`) or Python (`cursor-sdk`).

## Core Concepts
- **Local Runtime:** Runs against caller's local `cwd`. Reuses local tooling, environment, and credentials.
- **Cloud Runtime:** Runs on Cursor-hosted VMs against git repositories (`autoCreatePR: true`).
- **Authentication:** `CURSOR_API_KEY` in environment or pass `apiKey` in client configuration.

## Invocation Patterns

### 1. One-Shot Execution (`Agent.prompt`)
```typescript
import { Agent } from "@cursor/sdk";
const result = await Agent.prompt("Refactor utils for readability", {
  apiKey: process.env.CURSOR_API_KEY!,
  model: { id: "composer-2.5" },
  local: { cwd: process.cwd() },
});
```

### 2. Durable Multi-Turn (`Agent.create` + `agent.send`)
```typescript
import { Agent } from "@cursor/sdk";
await using agent = await Agent.create({
  apiKey: process.env.CURSOR_API_KEY!,
  model: { id: "composer-2.5" },
  local: { cwd: process.cwd() },
});
const run = await agent.send({ prompt: "Analyze codebase architecture" });
for await (const chunk of run.textStream) process.stdout.write(chunk);
```

## Instructions & SDK Implementation Workflow
1. **Runtime:** Select `local` for fast development loops; select `cloud` for detached CI jobs.
2. **Deterministic Lifecycle:** Guarantee resource release using `await using` (TS) or `with` context manager (Python).
3. **Error Handling:** Check `isRetryable` before retry loops. Log `run.id` and `agent.agentId`.

## Negative Constraints (Must NOT)
- [X] **Do not leak SDK resources**: Always wrap agents in `await using` or `with` blocks for deterministic cleanup.
- [X] **Do not hardcode fragile model IDs**: Prefer `composer-2.5` default or query `Cursor.models.list()`.
- [X] **Do not confuse Agent ID with Run ID**: Cloud `bc-` IDs identify agents; run IDs represent specific executions.
- [X] **Do not run uncontrolled retries**: Check `isRetryable` flag and obey rate limits before retrying failed runs.
