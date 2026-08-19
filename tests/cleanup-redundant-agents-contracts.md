# Cleanup Redundant Agents Contracts

## Purpose
Define the expected state of the repository after cleaning up redundant agent configurations.

## Contracts
1. The following directories MUST NOT exist in the root of the repository:
   - `.roo`
   - `.continue`
   - `.opencode`
   - `.claude`
2. The following files MUST NOT exist in the root of the repository:
   - `CLAUDE.md`
   - `.roorules`
3. The `.cursor` directory MUST exist (as it is required for the developing agent).
4. The `.cursorrules` file MUST exist.
