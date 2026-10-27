# Template: Testbed Brief

**Purpose:** Supply the `testbed-setup` skill with explicit scope and non-production authorization before real-host operations.

## Target, authority, and access

- **Host and expected identity:** `[hostname/IP and lab identity]`
- **Environment confirmation:** `[explicit authorized lab/dev/testbed confirmation]`
- **User and allowed privileges:** `[user; permitted sudo/root operations]`
- **Authentication reference:** `[configured credential provider or SSH key reference; never paste secrets]`
- **Snapshot/rollback readiness:** `[existing baseline/snapshot or authorized creation plan]`

## Mission

- **Goal and acceptance:** `[desired service behavior and observable success/failure cases]`
- **Allowed changes and exclusions:** `[hosts, packages, services, files, and forbidden operations]`
- **Dependencies and limits:** `[trusted package sources, versions/hashes, timeouts, attempt budget]`

Reuse explicit session authorization; ask only for missing required information. Follow Discovery -> Plan/dry-run -> Sequential execution -> Debug -> Functional verification. Return actual validation results, changed state, and a rollback recipe tied to the baseline. Do not treat this blank template as authorization, expose credentials, or claim completion while required checks fail.
