---
name: testbed-setup
description: Provision and verify an authorized non-production SSH testbed. Use when setting up a testbed, configuring a remote lab, or provisioning Docker lab environments.
triggers:
  - set up a testbed
  - configure a remote environment
  - build a lab
  - create a testbed for a specific area
---

# Testbed Setup

## Inputs and mandatory safety preflight

Establish the target hostname/IP, explicit non-production authorization, allowed privilege level, requested changes, authentication provider/key reference, and snapshot/rollback readiness before SSH. Reuse explicit session evidence; request only missing required information. Never solicit passwords or tokens in chat, reports, or process arguments. A hostname pattern cannot prove a host is non-production.

Inspect the supported `.ai-suite/layer4-evolutionary/validation/testbed-setup-preflight.sh` interface before invoking it: it is a real-host operational tool, not an offline test. It rejects known production patterns, probes reachability, and records an OS baseline under `testbed-state/`; execute only after the required authorization. Verify the host identity and approved change scope against the observed baseline.

## Operational protocol

1. **Discovery:** Inspect OS/kernel, service health, ports, packages, and existing state read-only. Record the minimum masked baseline and rollback instructions needed for the requested changes.
2. **Plan:** Compare desired and existing state. Prefer idempotent, verified package/configuration operations. Explain material state changes and rollback before performing them; use a supported dry-run where applicable and obey host/VIB-specific approval gates.
3. **Execute:** Apply dependent commands sequentially with verified exit statuses; parallelize only independent read-only checks. Use a bounded timeout and deterministic cleanup for each connection, subprocess, and temporary fixture.
4. **Debug:** On failure, inspect relevant stderr, service logs, and current state before retrying. Never repeat a failing command more than three times. Reassess once with a bounded alternative; if the cause remains external or unsafe, checkpoint and report the blocker.
5. **Verify:** Test requested service functionality and relevant negative/recovery cases. Service-active status alone is insufficient proof of the mission objective. Compare observed changes with the plan and preserve baseline/rollback evidence.

## Handover

Return a Validation Report with actual commands/statuses, observed behavior, failed or unavailable checks; a Change Summary; and a Rollback Recipe tied to the saved baseline. Retain user-facing recovery evidence and remove only task-created disposable files. Stop on identity mismatch, unapproved production risk, missing rollback prerequisite, or failed required verification.

## Negative Constraints (Must NOT)

- [X] Do not connect before the required safety preflight information and authorization are established.
- [X] Do not execute destructive production operations or treat this skill as permission for unrelated changes.
- [X] Do not install unverified third-party packages or VIBs; require a trusted source and applicable version/hash evidence.
- [X] Do not expose credentials in chat, shell history, command arguments, logs, or reports; use configured credential providers, key references, or protected input.
- [X] Do not claim setup success from partial command completion or retry failures indefinitely.
