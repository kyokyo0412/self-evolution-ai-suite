---
name: testbed-setup
description: Build and verify remote SSH testbeds via Idempotent Discovery-Execute-Debug-Verify loops. Use when setting up testbeds, configuring remote host environments, or provisioning Docker labs.
triggers:
  - set up a testbed
  - configure a remote environment
  - build a lab
  - create a testbed for a specific area
---

# Autonomous Testbed Engineer

Provisions, configures, and validates remote SSH testbeds by executing sequential commands against the target host following an idempotent **Discovery -> Execute -> Debug -> Verify** operational loop.

## Hard Safety Preflight (Mandatory)
Before establishing SSH connections, confirm with the user all four items:
1. Target Hostname/IP.
2. Explicit confirmation host is non-production (lab/testbed/dev).
3. Granted privilege level (sudo/root).
4. State snapshot/backup readiness.

Execute `.ai-suite/layer4-evolutionary/validation/testbed-setup-preflight.sh <host>` to reject production patterns (`*prod*`, `*production*`, `*-pr-*`), probe reachability, and snapshot OS baseline to timestamped file in `testbed-state/`.

## Operational Protocol & Execution Loop
For each setup task:
1. **Discovery:** SSH to host; inspect OS, kernel, ports, packages. Cache state in `testbed-state/<host>-<ts>.json`.
2. **Sequential Execution:** Run commands sequentially. Advance only when exit code is `0`. Prefer idempotent forms (`apt-get install -y --no-upgrade`, `systemctl enable --now`).
3. **Active Debugging:** On failure, inspect stderr, `/var/log/syslog`, `journalctl -xe`, and resolve root cause.
4. **Verification:** Probe service functionality after each step (`systemctl is-active`, curl health checks).

## Handover Artifacts
Emit Validation Report, Change Summary, and Rollback Recipe.

## Negative Constraints (Must NOT)
- [X] **Do not connect without safety preflight confirmation**: Explicit user authorization required.
- [X] **Do not run destructive deletion commands**: Forbid `rm -rf /`, `dd if=/dev/zero`, `mkfs.*`, `:(){:|:&};:`.
- [X] **Do not install unpinned third-party packages or VIBs**: Require verified path or hash.
- [X] **Do not leak credentials in shell history**: Use environment variables or stdin piping; export `HISTFILE=/dev/null`.
- [X] **Do not retry failing commands more than 3 times**: Execute active debugging between retries.
