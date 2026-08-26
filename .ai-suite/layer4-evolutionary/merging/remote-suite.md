---
name: remote-suite
description: Manage the full lifecycle of ai-suite on remote SSH hosts -- install, collect evolutions, push evolutions, check status, and remove. Use when the user asks to install ai-suite on a remote machine, deploy ai-suite to an SSH host, collect evolution from a remote host, push the evolved suite, check ai-suite status on a remote host, remove ai-suite from a remote host, or manage remote ai-suite in any way.
triggers:
  - install ai-suite
  - deploy ai-suite
  - remote ai-suite
  - check ai-suite status
  - check ai-suite on
  - remove ai-suite
  - uninstall ai-suite
  - collect evolution
  - push evolution
  - ai-suite on remote
  - verify ai-suite
  - verify the install
  - is ai-suite installed
  - reinstalled
---

# Remote Suite -- AI-Prompted Remote Lifecycle Manager

Manage ai-suite on remote SSH hosts using natural language. Covers all five operations:
**install * collect * push * status * remove**.

---

## Role

Act as the remote ai-suite operator. When triggered:

1. Parse the user's intent (which operation + which host(s)).
2. Build the exact shell command.
3. Run it and stream output to the user.
4. For `collect`: present the evolution report and print copy-paste git commands -- **never auto-commit**.
5. For `install`/`remove`: confirm success or report the error.

---

## Local Deployment Path (canonical -- never guess)

The local deployment root is **always** `~/.ai-suite-deploy/`. Do NOT search for
`.cursor-suite/`, `.ai-suite/` at `~`, or any other variant.

| Path | Purpose |
|---|---|
| `~/.ai-suite-deploy/` | Deployment root |
| `~/.ai-suite-deploy/.ai-suite/` | Suite source tree |
| `~/.ai-suite-deploy/.ai-suite/layer4-evolutionary/validation/` | Protocols, evolution reports |
| `~/.ai-suite-deploy/ai-suite enable` | Install script |
| `~/.ai-suite-deploy/ai-suite disable` | Uninstall script |
| `~/.ai-suite-deploy/ai-suite evolve` | Evolution sync script |
| `~/.cursor/skills/` | Deployed skills (agent reads these) |
| `~/.cursor/rules/` | Deployed rules (always-apply) |

> **Discovery rule:** When asked to verify any local installation, ALWAYS run
> `ls -la ~/` first to see the actual directory layout. Never use `find` with a
> hardcoded directory name as the first step.

---

## Operations

### 0. Local Status (verify installation on the current machine)

When the user asks "verify", "please verify", "confirm install", "is ai-suite installed",
or similar -- and no `USER@HOST` is present -- run this local check:

```bash
DEPLOY="$HOME/.ai-suite-deploy"

echo "=== Deploy root ===" && ls "$DEPLOY/" 2>/dev/null || echo "NOT INSTALLED"
echo "=== Scripts ===" && ls "$DEPLOY/"*.sh 2>/dev/null || echo "(none)"
echo "=== Meta ===" && ls "$DEPLOY/.ai-suite/layer4-evolutionary/validation/" 2>/dev/null || echo "(missing)"
echo "=== Skills (source) ===" && find "$DEPLOY/.ai-suite" -name '*.md' -path '*/skills/*' | sort
echo "=== Skills (deployed) ===" && ls ~/.cursor/skills/ 2>/dev/null || echo "(none)"
echo "=== Rules (deployed) ===" && ls ~/.cursor/rules/ 2>/dev/null || echo "(none)"
```

Then report: deploy root present [OK]/[X], script count, meta present [OK]/[X],
skill count (source vs deployed), rules deployed [OK]/[X].

### 1. Install (deploy ai-suite to a remote host)

Maps to: `bash ai-suite enable --scope remote --host USER@HOST [options]`

**Options extracted from the user's message:**

| User says | Flag added |
|---|---|
| "for cursor" (or default) | `--agent cursor` |
| "for claude" | `--agent claude` |
| "for all agents" | `--agent all` |
| "project /some/path" | `--remote-path PATH --remote-scope project` |
| "global" (default) | `--remote-scope global` |
| "preview" / "dry run" | `--dry-run` |

**Example commands:**

```bash
# Default: cursor agent, global scope
bash ai-suite enable --scope remote --host "alice@dev.example.com"

# Claude agent
bash ai-suite enable --scope remote --host "alice@dev.example.com" --agent claude

# All agents + Custom domain pack
bash ai-suite enable --scope remote \
  --host "alice@dev.example.com" \
  --agent all --domain my-company

# Project-scoped install
bash ai-suite enable --scope remote \
  --host "alice@dev.example.com" \
  --remote-path "/home/alice/myproject" \
  --remote-scope project

# Multiple hosts (run once per host)
bash ai-suite enable --scope remote --host "alice@host1"
bash ai-suite enable --scope remote --host "bob@host2"
```

### 2. Collect (pull remote evolutions into local git)

Maps to: `bash ai-suite evolve collect --host USER@HOST [--remote-path PATH] [--dry-run]`

After running, the agent MUST:
- Display the evolution report from `.ai-suite/layer4-evolutionary/reflection/evolutions/`
- Print the copy-paste git commands output by the script
- State: **"Review the diff before running the git commands. Do not auto-commit."**

**Example commands:**

```bash
# Collect from one host
bash ai-suite evolve collect --host "alice@dev.example.com"

# Collect from multiple hosts
bash ai-suite evolve collect \
  --host "alice@dev.example.com" \
  --host "bob@ci.example.com"

# Collect from a specific project path
bash ai-suite evolve collect \
  --host "alice@dev.example.com" \
  --remote-path "/home/alice/myproject"

# Preview only
bash ai-suite evolve collect --host "alice@dev.example.com" --dry-run
```

### 3. Push (send local evolved suite to remote hosts)

Maps to: `bash ai-suite evolve push --host USER@HOST [--remote-path PATH] [--remote-scope SCOPE] [--dry-run]`

**Example commands:**

```bash
# Push to one host
bash ai-suite evolve push --host "alice@dev.example.com"

# Push to multiple hosts
bash ai-suite evolve push \
  --host "alice@dev.example.com" \
  --host "bob@ci.example.com"

# Push to a specific project
bash ai-suite evolve push \
  --host "alice@dev.example.com" \
  --remote-path "/home/alice/myproject" \
  --remote-scope project
```

### 4. Status (check remote installation)

Probes the remote host to verify the suite is installed and reports skill count.

```bash
ssh USER@HOST "
  DEPLOY=\$HOME/.ai-suite-deploy
  if [ -d \"\$DEPLOY/.ai-suite/layer3-registry/core\" ]; then
    count=\$(find \"\$DEPLOY/.ai-suite/layer3-registry/core\" -name '*.md' | wc -l)
    echo \"[ai-suite] installed -- \$count core skill(s) at \$DEPLOY\"
  else
    echo '[ai-suite] NOT installed at \$DEPLOY'
  fi
"
```

### 5. Remove (uninstall from remote host)

Maps to: `bash ai-suite disable --scope remote --host USER@HOST [options]`

**Example commands:**

```bash
# Remove global install
bash ai-suite disable --scope remote --host "alice@dev.example.com"

# Remove a specific project install
bash ai-suite disable --scope remote \
  --host "alice@dev.example.com" \
  --remote-path "/home/alice/myproject" \
  --remote-scope project

# Remove for a specific agent only
bash ai-suite disable --scope remote \
  --host "alice@dev.example.com" \
  --agent claude
```

---

## Intent Recognition

Map the user's words to an operation:

| User's words | Operation |
|---|---|
| "install", "deploy", "set up", "enable", "bootstrap" | **install** |
| "collect", "sync", "pull", "fetch", "gather" | **collect** |
| "push", "send evolution", "update remote", "deploy evolution" | **push** |
| "status", "check", "verify", "please verify", "reinstalled", "confirm install", "is it installed", "what's installed" | **local status** (no host) or **remote status** (with host) |
| "remove", "disable", "uninstall", "clean up", "take off" | **remove** |
| Ambiguous / just `ai-suite on USER@HOST` | **install** (default) |

### Host extraction

Extract all `USER@HOST` patterns from the user's message.

- If a `USER@HOST` is found -> use the **remote** operation (Operations 1-5).
- If **no** `USER@HOST` is found and the intent is status/verify -> use **Operation 0 (Local Status)** immediately. Do NOT ask for a host.
- If **no** `USER@HOST` is found and the intent is install/collect/push/remove -> ask:

> "Which remote host? (format: `user@hostname`)"

Do NOT proceed until the user provides a host (for remote operations only).

### Multiple hosts

If the user lists multiple `USER@HOST` patterns (e.g. "alice@host1 and bob@host2"), run the operation for each host in sequence. Report success/failure per host.

---

## Step-by-Step Execution

### Step 1 -- Identify operation and hosts

- Operation: local-status / install / collect / push / remote-status / remove (see table above)
- **Local status shortcut:** if intent is verify/status and no `USER@HOST` is present, run Operation 0 immediately and skip Steps 2-4.
- Hosts: extract `USER@HOST` patterns -- for remote ops, ask if none found
- Options: agent, domain, remote-path, remote-scope, dry-run

### Step 2 -- Safety preflight

Before running any command:

1. **Script check:** Confirm `ai-suite enable`, `ai-suite disable`, and `ai-suite evolve` exist in the workspace. If any is missing, report the missing file and stop.
2. **Production guard:** If the host contains `prod` or `prd`, warn:
   > "[WARN] `USER@HOST` looks like a production target. Please confirm you want to proceed."
   Wait for explicit confirmation before continuing.

### Step 3 -- Build and run the command

Build the exact shell command per the Intent Recognition table and run it.
Stream output so the user sees progress in real time.

### Step 4 -- Present results

**Install / remove:**
- Confirm success per host, or report the error and suggest checking SSH connectivity.

**Collect:**
- Show the evolution report from `.ai-suite/layer4-evolutionary/reflection/evolutions/` (or "no changes" if empty).
- Print the copy-paste git commands verbatim, clearly boxed.
- State: **"Review the diff before running the git commands. Do not auto-commit."**
- If `--dry-run`: confirm "No local files were changed. This was a preview."

**Push:**
- Confirm which hosts were updated. Report any failures.

**Status:**
- Report installed / not-installed + skill count per host.

---

## Examples

### Install on a single host

```
User:  install ai-suite on alice@dev.example.com
Agent: bash ai-suite enable --scope remote --host "alice@dev.example.com"
```

### Collect remote evolution

```
User:  collect evolution from alice@dev.example.com
Agent: bash ai-suite evolve collect --host "alice@dev.example.com"
       [displays report + copy-paste git commands]
```

### Push evolved suite to multiple remotes

```
User:  push the evolved suite to alice@host1 and bob@host2
Agent: bash ai-suite evolve push --host "alice@host1"
       bash ai-suite evolve push --host "bob@host2"
```

### Check status

```
User:  check ai-suite status on alice@dev.example.com
Agent: ssh alice@dev.example.com "... status probe ..."
       -> [ai-suite] installed -- 6 core skill(s) at /home/alice/.ai-suite-deploy
```

### Remove from a remote host

```
User:  remove ai-suite from alice@dev.example.com
Agent: bash ai-suite disable --scope remote --host "alice@dev.example.com"
```

### Dry-run preview

```
User:  preview installing ai-suite on alice@dev.example.com
Agent: bash ai-suite enable --scope remote --host "alice@dev.example.com" --dry-run
       No changes were made. This was a preview.
```

---

## Safety

- **Never auto-commit.** After `collect`, always print git commands for manual review.
- **Never skip the production guard.** Hosts matching `prod`,  require explicit user confirmation.
- **Never invent a host.** If no `USER@HOST` is found in the user's message, ask before proceeding.
- **Never run destructive remote commands** beyond what `ai-suite enable`, `ai-suite evolve`, or `ai-suite disable` prescribe.
- Check that required scripts exist (`ai-suite enable`, `ai-suite evolve`, `ai-suite disable`) as a preflight before running any operation.

---

## Negative Constraints (Must NOT)

- [X] Do not auto-commit or run `git push` automatically.
- [X] Do not proceed with `prod` hosts without explicit user confirmation.
- [X] Do not guess a host -- always ask if none is provided.
- [X] Do not run `push` when the user asked `collect`, or vice versa.
- [X] Do not silently add `--dry-run` -- state it explicitly if used.
- [X] Do not run `install` if the required scripts are missing from the workspace.
- [X] Do not combine incompatible flags (e.g., `--remote-scope project` without `--remote-path`).
