---
name: local-suite
description: Manage the local lifecycle of ai-suite — install and remove on the local machine. Use when the user asks to install ai-suite locally, enable ai-suite globally, remove ai-suite locally, or manage the local ai-suite installation.
triggers:
  - enable ai suite
  - install ai suite
  - local ai suite
  - disable ai suite
  - remove ai suite
  - push evolution
  - push the evolution
  - update ai suite
  - collect evolution from local
  - collect local
---

# Local Suite — AI-Prompted Local Lifecycle Manager

Manage ai-suite on the local machine using natural language. Covers local project and global scope operations.

## Operations

### 1. Install / Update (enable, update, or push evolution locally or globally)

Maps to: `bash ai-suite enable --scope [project|global] [options]`

**Note on updating/pushing:** If the user asks to "push the evolution" or "update" locally, this maps to the Install operation. Re-running `ai-suite enable` safely overwrites the deployed skills with the newly evolved ones.

**Options extracted from user's message:**
- "global" -> `--scope global`
- "local", "project" -> `--scope project` (default)
- "for cursor" -> `--agent cursor` (default)
- "for claude" -> `--agent claude`
- "for all agents" -> `--agent all`
- "preview", "dry run" -> `--dry-run`

**Example commands:**
```bash
# Local project scope for cursor
bash ai-suite enable --scope project --agent cursor

# Global scope for all agents
bash ai-suite enable --scope global --agent all
```

### 2. Remove (disable ai-suite locally or globally)

Maps to: `bash ai-suite disable --scope [project|global] [options]`

**Example commands:**
```bash
# Disable globally
bash ai-suite disable --scope global

# Disable for current project
bash ai-suite disable --scope project
```

### 3. Collect (sync local evolutions back to repo)

If the user asks to "collect evolution from local cursor", the skills are flattened in `~/.cursor/skills/` and must be mapped back to their tiered directories in `.ai-suite/`. 

Run this exact Bash snippet to detect and collect changes:

```bash
echo "Scanning for local Cursor evolutions..."
any_changed=false
for d in ~/.cursor/skills/*; do
  [[ -d "$d" ]] || continue
  skill_name=$(basename "$d")
  src=$(find .ai-suite -name "${skill_name}.md" | head -n 1)
  if [[ -n "$src" ]]; then
    if ! cmp -s "$d/SKILL.md" "$src"; then
      echo "Changes detected in $skill_name"
      diff -u "$src" "$d/SKILL.md" || true
      cp "$d/SKILL.md" "$src"
      any_changed=true
    fi
    if [[ -d "$d/scripts" ]]; then
      src_dir=$(dirname "$src")
      mkdir -p "$src_dir/scripts/${skill_name}"
      if ! diff -r "$src_dir/scripts/${skill_name}" "$d/scripts" >/dev/null 2>&1; then
          echo "Changes detected in scripts for $skill_name"
          cp -r "$d/scripts/"* "$src_dir/scripts/${skill_name}/"
          any_changed=true
      fi
    fi
  fi
done
if ! $any_changed; then echo "No local evolutions found."; fi
```

After running, if changes were collected, you MUST write an Evolution Report manually summarizing the diffs, and output copy-paste git commands.

## Step-by-Step Execution

1. Identify the operation (install/enable vs remove/disable) and scope (project vs global).
2. Check if `ai-suite enable` or `ai-suite disable` exist in the workspace. If they do not exist, report an error.
3. Run the appropriate command and stream output to the user.
4. Confirm success or report the error to the user.

## Negative Constraints (Must NOT)
- �M-^]M-^L Do not modify files outside the `.ai-suite` directory unless explicitly requested.
