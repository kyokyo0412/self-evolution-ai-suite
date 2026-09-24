# Template: Testbed Brief (Hand-Off to `testbed-setup` Skill)
**Purpose:** Compact hand-off brief for the `testbed-setup` skill to execute Discovery -> Execute -> Debug -> Verify autonomously.

## 1. Target Environment & Access
- **Host(s):** `[IP or hostname]`
- **User:** `[username]`
- **Authentication:** `[password OR path to SSH key]`
- **Privilege Level:** `[sudo / root]`
- **Environment:** `[lab | dev | staging]` (MUST be non-production)

## 2. Mission Objective
- **Goal:** `[e.g. "Dockerized OVS-DPDK lab with iperf3 on :5201"]`
- **Setup steps / refs:** `[optional command list or wiki links]`

## 3. Operational Protocol
1. Discovery (probe OS/kernel/deps) -> 2. Sequential execution -> 3. Active debugging (inspect syslog/journalctl) -> 4. Functional verification -> 5. Handover (Validation Report, Change Summary, Rollback Recipe).
