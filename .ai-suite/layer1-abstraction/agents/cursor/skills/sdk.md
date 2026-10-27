---
name: sdk
description: Guide users building apps, scripts, and CI pipelines with the Cursor SDK (@cursor/sdk or cursor-sdk). Use when integrating, configuring, or running Cursor agents programmatically.
triggers:
  - sdk
---
# Cursor SDK

Guides programmatic execution of Cursor agents using TypeScript (`@cursor/sdk`) or Python (`cursor-sdk`).

## Instructions & SDK Implementation Workflow
1. Identify the requested runtime, installed SDK package and version from manifests, lockfiles and local package metadata. Inspect the installed type definitions, examples or bundled official documentation before selecting APIs. If absent, use current official documentation only when browsing is authorized; otherwise label the version/API UNVERIFIED and provide a draft rather than inventing executable calls.
2. Verify authentication configuration, runtime side effects and model discovery against that version. Use the user-selected model or the documented default; do not embed a guessed fixed model identifier. Keep credentials in configured providers or environment variables and redact them from logs.
3. Implement only the requested local or cloud operation. Cloud runs, repository writes and PR creation need authorization for those specific effects. Do not turn on automatic PR creation by default.
4. Use the verified SDK disposal/context-management API, bounded request timeouts and cancellation. Retry only documented retryable failures with a finite attempt limit and backoff. Record available run/agent identifiers without assuming property names.
5. Validate with local types, tests and mocks first. Execute remote calls only within the authorized scope, and report exact version, commands, observed outcomes and verification limits.

## Negative Constraints (Must NOT)
- [X] Do not present unverified SDK methods, configuration keys, model IDs or lifecycle APIs as established facts.
- [X] Do not hardcode or log API credentials.
- [X] Do not leak agents, streams or subprocesses; verify deterministic cleanup on success, failure and cancellation.
- [X] Do not execute uncontrolled retries or create PRs without authorization.
