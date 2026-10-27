---
name: local-suite
description: Manage ai-suite on the local machine with explicit agent and scope selection. Use when installing, updating, removing, inspecting, or collecting a local ai-suite installation.
triggers:
  - enable ai suite
  - install ai suite
  - local ai suite
  - disable ai suite
  - remove ai suite
  - update ai suite
  - update local ai suite
  - collect evolution from local
  - collect local
---

# Local Suite Lifecycle

## Inputs and authority

Identify the operation, local project or global scope, project path when applicable, and selected agent. Supported agents are `cursor`, `claude`, `codex`, `opencode`, `continue`, `roo-code`, and explicit `all`. Resolve these from the request and active environment before running commands; do not silently use the CLI's Cursor default for another agent. Local updates mean enabling the selected installation. Requests naming a remote host belong to `evolve-collect` or `remote-suite`; clarify ambiguous "push" requests before mutating either target.

Resolve the actual source or installed `ai-suite` launcher and run from its directory; adapt the relative examples to that verified path. Session authorization and filesystem permissions govern writes.

## Operational Modes

Set `scope` and `agent` from the resolved selection, preserving them for every command:

| Operation | Command |
| --- | --- |
| Enable / Update | `bash ai-suite enable --scope "$scope" --agent "$agent"` |
| Disable / Remove | `bash ai-suite disable --scope "$scope" --agent "$agent"` |
| Collect Local | `bash ai-suite evolve collect --local --agent "$agent"` |

Add `--project "$project_path"` for a selected project target. Use `--dry-run` to inspect target, scope, and planned changes before a write when supported; a dry-run is evidence of a plan, not proof an installation succeeded. For status-only requests, inspect the selected native files and ownership manifests without mutation; do not invent an unsupported `status` subcommand.

## Instructions and verification

1. Inspect status and relevant managed-artifact ownership; preserve user edits and unrelated targets. Verify the command selects the intended operation, agent, and scope.
2. Execute the selected command once authorized, capture its exit status, and inspect the resulting target or report. A failed command is not success; inspect its specific error before considering a bounded retry.
3. After collection run `bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh` from the verified source checkout. Differing local files remain in durable pending merge bundles; inspect their provenance, reports, and diffs before resolving incoming changes. Report an unavailable source validator as a verification limit.
4. Use deterministic cleanup for disposable fixtures. Retain pending bundles, journals requiring recovery, and edited managed files for review; never overwrite conflicts or activate global agents automatically after collection.

Report selected targets, actual commands/statuses, observed changes, retained conflicts, and remaining recovery actions. Stop mutation on ownership ambiguity, failed validation, or missing essential authorization.

## Negative Constraints (Must NOT)

- [X] Do not modify unrequested targets or run remote commands for a local request.
- [X] Do not remove user-owned artifacts during disable; remove only verified suite-owned artifacts.
- [X] Do not skip validation after evolution collection or claim a dry-run completed a real update.
- [X] Do not commit or push autonomously.
