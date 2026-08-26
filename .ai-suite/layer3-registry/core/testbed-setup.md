---
name: testbed-setup
description: Autonomously build and verify a remote testbed (Linux VM, container host) over SSH following an Idempotent Discovery -> Execute -> Debug -> Verify loop. Use when the user asks to set up a testbed, install/configure a remote environment, or build a Dockerized lab. Includes mandatory safety preflight to refuse known-production targets.
triggers:
  - set up a testbed
  - configure a remote environment
  - build a lab
  - create a testbed for a specific area
---

# Autonomous Testbed Engineer

Build and verify a remote testbed by directly executing SSH commands against the target host. Every action follows **Discovery -> Execute -> Debug -> Verify** with idempotency and structured `[EXEC]`/`[STATUS]`/`[DEBUG]` logging.

## Hard Safety Preflight (run first, every time)

Before any SSH connection, confirm with the user **all four** of:

1. **Hostname/IP** of target (echoed back).
2. **Explicit confirmation** the host is **non-production** (testbed/lab/dev).
3. **Sudo/root scope** -- what privilege level is granted.
4. **Snapshot/backup state** -- if the testbed has prior state worth preserving.

Run `bash .ai-suite/layer4-evolutionary/validation/testbed-setup-preflight.sh <host>` (provided with this skill) to:
- Reject hostnames matching `*prod*`, `*production*`, `*-pr-*`, or any user-provided blocklist.
- Probe reachability without state change.
- Capture the existing `uname -a`, `lsb_release -a`, mounted filesystems, listening sockets -- saved to a timestamped baseline file for rollback.

**Refuse to proceed** if the user has not confirmed all four items, or if `preflight.sh` returns non-zero. Ask the user to override explicitly if they insist.

## Mission Inputs (collect these)

| Field | Example |
|------|---------|
| Host(s) | `10.x.y.z` or `lab-01.eng` |
| User | `root` |
| Auth | password (env var) or `~/.ssh/id_ed25519` |
| Privilege | sudo / root |
| Goal | "Linux host with nginx installed + specific patch" |
| Setup steps | numbered list from user |
| Command references | links/snippets |

## Operational Loop

For every task in the user's setup list:

1. **Discovery**
   - SSH in, capture: OS, kernel, CPU arch, existing packages relevant to the task, current service state.
   - Cache the baseline in `testbed-state/<host>-<ts>.json` so failures can be rolled back.

2. **Sequential Execution**
   - Run one command at a time. Do **not** proceed until exit code is `0` and the expected post-condition holds.
   - Prefer idempotent forms (`apt-get install -y --no-upgrade`, `systemctl enable --now`, `[ -d X ] || mkdir -p X`).

3. **Active Debugging**
   - On non-zero exit, **do not ask permission** to fix -- analyze:
     - `stderr` from the failed command
     - `/var/log/syslog`, `dmesg`, `journalctl -xe`, `/var/log/messages`
     - Service-specific logs (e.g., `/var/log/nginx/error.log`).
   - Identify root cause: missing dep, port conflict, version mismatch, FS quota, kernel param, AppArmor/SELinux.
   - Apply corrective action and re-run.

4. **Verification**
   - After config: run a functional test -- `systemctl is-active <svc>`, `curl -sf http://host/health`, `docker ps -a`, etc.
   - Capture exit code + a snippet of output as evidence.

## Logging Format (mandatory)

For every action emit:

```
[EXEC] <command>
[STATUS] OK (exit 0)        # or FAIL (exit N)
[DEBUG] <root cause + corrective action>   # only on FAIL
```

End each phase with a **block summary**: how many EXEC, how many FAIL, how many recovered.

## Final Handover

1. **Validation Report** -- `systemctl status` (or equivalent) of every service brought up, plus health probes.
2. **Change Summary** -- packages installed, files modified (with diff), service states changed, kernel params adjusted.
3. **Rollback Recipe** -- exact commands to undo the changes (from the baseline file in `testbed-state/`).
4. **Confirmation** -- testbed is ready for use.

## Negative Constraints (Must NOT)

- [X] Do not connect to a host until the safety preflight has explicit user confirmation.
- [X] Do not run `rm -rf /` patterns, `dd if=/dev/zero of=/dev/sdX`, `mkfs.*`, `:(){:|:&};:`, `chmod -R 777 /`, or any `iptables -F` on a production-looking host.
- [X] Do not install packages from untrusted PPAs or third-party `.vib` files without the user pinning a hash or path.
- [X] Do not stash credentials in shell history (use env vars or stdin piping; export `HISTFILE=/dev/null` for the session).
- [X] Do not modify firewall, kernel modules, or networking on a multi-tenant host without the user explicitly listing it as in-scope.
- [X] Do not retry a failing command more than 3 times without a debug step in between.

## Verification

When done, the user can confirm with:

```bash
# On the lab host
systemctl --failed                    # should be empty
journalctl -p err -b --no-pager | tail # should be clean for the time window
<service-specific health check>
```
