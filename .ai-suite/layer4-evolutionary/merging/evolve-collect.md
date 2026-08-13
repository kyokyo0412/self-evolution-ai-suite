---
name: evolve-collect
description: Collect and push ai-suite evolutions between remote SSH hosts and the local git repo. Use when the user asks to collect evolution, sync reflection, pull suite changes, gather remote updates, push suite to remote, deploy evolution, or update a remote host with the evolved ai-suite.
triggers:
  - collect evolution
  - sync reflection
  - pull suite changes
  - evolve collect
  - collect remote
  - push evolution
  - sync remote reflection
  - gather remote updates
  - deploy evolution
  - update remote with suite
  - collect cursor suite
  - fetch remote reflection
---

# Evolve Collect — Remote Evolution Sync Skill

Orchestrate the full **collect → review → push** loop for ai-suite evolutions between remote SSH hosts and the local git repository.

## CORE EVOLUTION PRINCIPLES

When reviewing or collecting evolutions, ensure they adhere to:
- **Semantic Understanding:** Evolutions must be based on deep semantic understanding of the prompt, skills, and rules.
- **Agent Effectiveness:** Evolutions must improve how the AI suite Agent understands and process the prompt, skills, rules, or other artifacts.
- **End-User Usability:** Evolutions must make the AI suite easy to be used easy by the end user.
- **Isolation:** When pulling evolution for an AI suite project, the evolution MUST be integrated into the AI suite being developed AND the Augmented Agent.

## Role


Act as the evolution sync coordinator. When triggered, you:

1. Parse the user's intent (collect vs push, host(s), optional path, dry-run flag).
2. Run `ai-suite evolve` with the correct arguments.
3. Present the evolution report or push confirmation to the user.
4. Print copy-paste git commands and **stop** — never auto-commit.

---

## Trigger Recognition

This skill is active when the user's message contains any of:

| Keywords | Intent |
|---|---|
| "collect", "sync", "pull", "fetch", "gather" | `ai-suite evolve collect` |
| "push", "deploy", "send evolution", "update remote" | `ai-suite evolve push` |
| "preview", "dry-run", "dry run", "what changed", "show changes" | append `--dry-run` |
| `USER@HOST` pattern or explicit host mention | extract as `--host USER@HOST` |
| "path /some/path", "at /some/path", "project /some/path" | extract as `--remote-path PATH` |
| "project scope" or "project install" | append `--remote-scope project` to push |

---

## Instructions

### Step 1 — Parse intent

Extract the following from the user's message:

- **sub-command**: `collect` (default) or `push`
- **hosts**: one or more `USER@HOST` strings; if none found, **ask the user** before proceeding:
  > "Which remote host should I collect from? (format: `user@hostname`)"
- **remote-path**: optional; present only if the user explicitly provides a path
- **dry-run**: `true` if the message contains "preview", "dry", "what changed", or "show changes"
- **remote-scope**: `project` if the user says "project scope" or "project install"; default is `global`

### Step 2 — Build the command

```
bash ai-suite evolve <sub-command> \
  --host "USER@HOST" \
  [--host "USER@HOST2" ...] \
  [--remote-path "PATH"] \
  [--remote-scope project|global] \
  [--dry-run]
```

Examples:

```bash
# Collect from one host (global, default remote path)
bash ai-suite evolve collect --host "alice@dev.example.com"

# Collect from multiple hosts
bash ai-suite evolve collect \
  --host "alice@dev.example.com" \
  --host "bob@ci.example.com"

# Collect from a specific project path
bash ai-suite evolve collect \
  --host "alice@dev.example.com" \
  --remote-path "/home/alice/myproject"

# Preview without modifying local files
bash ai-suite evolve collect --host "alice@dev.example.com" --dry-run

# Push evolved suite back to one host
bash ai-suite evolve push --host "alice@dev.example.com"

# Push to multiple hosts
bash ai-suite evolve push \
  --host "alice@dev.example.com" \
  --host "bob@ci.example.com"

# Push to a specific remote project scope
bash ai-suite evolve push \
  --host "alice@dev.example.com" \
  --remote-path "/home/alice/myproject" \
  --remote-scope project
```

### Step 3 — Run the command

Execute the command in the terminal. Stream the output so the user can see progress.

### Step 4 — Present results

**After `collect`:**

- Show the contents of any evolution report written to `.ai-suite/layer4-evolutionary/reflection/evolutions/`.
- Print the **copy-paste git commands** output by the script verbatim, clearly boxed.
- State explicitly: **"Review the diff before running the git commands. Do not auto-commit."**
- If `--dry-run` was used: confirm "No local files were changed. This was a preview."

**After `push`:**

- Confirm which hosts were updated successfully.
- If any host failed, report the failure clearly and suggest checking SSH connectivity.

---

## Usage

### Scope A — Remote user's global ai-suite (most common)

The remote host has ai-suite installed under `$HOME/.ai-suite-deploy/` (the default). This is the global user scope: all projects on that host benefit.

```
User:  collect evolution from alice@dev.example.com
Agent: bash ai-suite evolve collect --host "alice@dev.example.com"
```

```
User:  push the evolved suite to alice@dev.example.com
Agent: bash ai-suite evolve push --host "alice@dev.example.com"
```

### Scope B — Specific remote project

The user wants to target a single project directory on the remote, not the user-global install.

```
User:  collect evolution from alice@dev.example.com project /opt/myapp
Agent: bash ai-suite evolve collect --host "alice@dev.example.com" --remote-path "/opt/myapp"
```

```
User:  push to alice@dev.example.com at /opt/myapp project scope
Agent: bash ai-suite evolve push \
         --host "alice@dev.example.com" \
         --remote-path "/opt/myapp" \
         --remote-scope project
```

### Scope C — Multiple hosts

```
User:  sync reflection from alice@host1 and bob@host2
Agent: bash ai-suite evolve collect \
         --host "alice@host1" \
         --host "bob@host2"
```

---

## Safety Constraints

- **Never auto-commit.** The AI must not run `git add` or `git commit` after a collect. Always wait for the user to copy-paste and execute the git commands manually.
- **Always show the evolution report** (or confirm no changes) before presenting git commands.
- **Always ask for `--host`** if none is provided in the user's message. Do not guess.
- **Never run destructive remote commands.** `ai-suite evolve push` only rsyncs and re-runs `ai-suite enable`; it does not delete remote files beyond the managed `.ai-suite/` directory.

---

## Negative Constraints (Must NOT)

- ❌ Do not auto-commit or run `git push` automatically.
- ❌ Do not skip presenting the evolution report even if it is long.
- ❌ Do not invent a `--host` if the user did not supply one — ask first.
- ❌ Do not run `push` when the user asked for `collect`, or vice versa — resolve ambiguity by restating your interpretation before executing.
- ❌ Do not use `--dry-run` silently; if you add it, say so explicitly.
- ❌ Do not proceed if `ai-suite evolve` is not found in the workspace root; tell the user to check their setup.
