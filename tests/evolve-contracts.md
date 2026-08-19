# Architecture Contract: ai-suite evolve
# Phase 2 artifact — defines interface, module boundaries, and stub behaviours.
# Contract tests in test-evolve-contracts.sh will verify these against the real script.

## Module Boundary

ai-suite evolve MUST:
  - Be located at SUITE_ROOT/ai-suite evolve (sibling of enable/disable).
  - Source SUITE_ROOT/.cursor-suite/meta/_portable.sh at startup (fail fast if missing).
  - Exit 0 on success, non-zero on any error.
  - Support --dry-run on both sub-commands (no mutations, informational only).

## Sub-command: collect

  Signature:
    ai-suite evolve collect --host USER@HOST [--host USER@HOST2 ...]
                            [--remote-path PATH]
                            [--dry-run]

  Invariants:
    C1. --host is required; absence exits non-zero with message containing "--host is required".
    C2. Default --remote-path is the literal string '$HOME/.cursor-suite-deploy'
        (resolved on the REMOTE, not locally).
    C3. Changed files are determined by: rsync --dry-run --checksum from remote to a tmpdir,
        then comparing the tmpdir to local .cursor-suite/.
    C4. Only .cursor-suite/ subtree files are collected (not enable/disable scripts themselves,
        which may have been customised remotely — caller decides to update those separately).
    C5. An evolution report is written to:
          .cursor-suite/layer4-evolutionary/reflection/evolutions/<YYYYMMDD-HHMMSS>-<sanitized-host>.md
        The report MUST contain:
          - Host
          - Timestamp (UTC)
          - List of changed/added/removed files (relative to .cursor-suite/)
          - Full unified diff per changed file
        No report is written if no files changed.
    C6. After copying, validate-suite.sh is run on .cursor-suite/skills/;
        warnings are printed but do NOT cause a non-zero exit.
    C7. Printed copy-paste git commands are ALWAYS emitted at end if at least 1 file changed:
          git add .cursor-suite/
          git commit -m "feat(evolution): collect remote changes from HOST at TIMESTAMP"
    C8. --dry-run prints the diff but copies nothing and creates no report.

## Sub-command: push

  Signature:
    ai-suite evolve push --host USER@HOST [--host USER@HOST2 ...]
                         [--remote-path PATH]
                         [--remote-scope global|project]
                         [--dry-run]

  Invariants:
    P1. --host is required; absence exits non-zero.
    P2. Default --remote-path is '$HOME/.ai-suite'.
    P3. Default --remote-scope is 'global'.
    P4. For each host: rsync .ai-suite/ + enable/disable/evolve scripts to remote without --delete,
        then ssh HOST "bash REMOTE_PATH/ai-suite enable --scope REMOTE_SCOPE".
    P5. Hosts are processed in sequence.  On any failure the script records the host
        as failed, continues to remaining hosts, and exits non-zero at the end.
    P6. --dry-run prints the rsync and ssh commands but does not execute them.

## Exit codes
  0  = success (or --dry-run completed, or no changes detected)
  1  = bad invocation (missing required arg, unknown flag)
  2  = source files missing (suite not found next to script)
  3  = all-hosts-failed (push sub-command, every host failed)
 10  = partial failure (push, at least one host failed but not all)
