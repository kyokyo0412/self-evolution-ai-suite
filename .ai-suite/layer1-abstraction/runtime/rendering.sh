#!/usr/bin/env bash
# Render lazy skill indexes, scoped policies and stable memory entry points.

_render_skill_index() {
  local suite="$1" agent="$2" skill_file sname sdesc listing
  listing=$(get_all_skill_files "$suite" "$agent") || return
  printf '## AI Suite Skills\n\n### Skill Index\n'
  while IFS= read -r skill_file; do
    [[ -f "$skill_file" ]] || continue
    sname=$(sed -n 's/^name: *//p' "$skill_file" | head -1)
    sdesc=$(sed -n 's/^description: *//p' "$skill_file" | head -1)
    printf -- '- **%s** -- %s\n' "$sname" "$sdesc"
  done <<< "$listing"
}

_render_base_guidance() {
  local target="$1" agent="$2"
  cat <<GUIDANCE

### Capability selection and precedence
Select skills by their documented invocation conditions and load detailed workflows only when relevant.
For complex authorized tasks use prompt-compiler Inline analysis mode and continue the task.
For a reusable prompt request use Draft prompt mode and return the requested prompt artifact.
Current user instructions and applicable host
policies take precedence over suite defaults. Never commit or push autonomously, including when a
skill requests local commits. Report plans, decisions, evidence and results concisely.

### Reflection Protocol
When the user says \`Run Reflection\`, follow $target/meta/reflection-protocol.md.
After a complex implementation or repeated failed attempts, apply that protocol once, within
the authorized task scope. Keep evolution reports and leave changes uncommitted.

### Memory System
Your agent name is \`$agent\`. Review project memory in \`.ai-memory/$agent/index/\`
and global task history in \`~/.ai-suite/memory/$agent/tasks/\`.
Use the installed \`$target/scripts/memory.sh\` helpers to discover, search and update memory:
\`ai_memory_summary $agent\` and \`ai_memory_search $agent "keyword"\`.
Read \`$target/skills/<skill-name>/SKILL.md\` for a selected workflow.

GUIDANCE
}

_render_policy_directory() {
  local directory="$1" source_file
  [[ -d "$directory" ]] || return 0
  for source_file in "$directory"/*; do
    [[ -f "$source_file" ]] || continue
    _strip_rule_frontmatter "$source_file"
    printf '\n'
  done
}

_render_codex_directive_references() {
  local suite="$1" target="$2" relative directory source_file filename
  printf '### Installed Directive References\n'
  printf 'Load the applicable installed directives from %s/directives/:\n' "$target"
  for relative in layer3-registry/directives layer3-registry/safety \
    "layer1-abstraction/agents/codex/directives"; do
    directory="$suite/$relative"
    [[ -d "$directory" ]] || continue
    for source_file in "$directory"/*; do
      [[ -f "$source_file" ]] || continue
      filename=$(basename "$source_file")
      filename=$(printf '%s' "$filename" | sed -E 's/\.(md|mdc)$/.md/')
      printf -- '- `%s/directives/%s`\n' "$target" "$filename"
    done
  done
  printf '\n'
}

_render_policies() {
  local suite="$1" agent="$2" target="$3" relative domain
  printf '## AI Suite Directives & Rules\n\n'
  if [[ "$agent" == cursor ]]; then
    printf 'Essential policies are active in %s/rules/cursor-suite-{agent-directives,primary-rule,production-safety}.mdc.\n' "$target"
    printf 'Cursor continuation behavior is defined once in %s/rules/cursor-suite-interactive-workflow.mdc.\n' "$target"
  else
    for relative in layer3-registry/directives/agent-directives.md \
      layer3-registry/directives/primary-rule.md layer3-registry/safety/production-safety.md; do
      _strip_rule_frontmatter "$suite/$relative"
      printf '\n'
    done
    if [[ "$agent" == codex ]]; then
      _render_codex_directive_references "$suite" "$target"
    fi
  fi
  printf 'Before coding or review, load %s/meta/layer3-registry/directives/code-quality.md.\n' "$target"
  printf 'For documented safety-critical work, load %s/meta/layer3-registry/directives/nuclear-safety.md.\n' "$target"
  printf 'Use %s/meta/layer3-registry/directives/step-action-visibility.md for progress reporting.\n' "$target"
  [[ "$agent" != cursor ]] || return 0
  for relative in layer3-registry/rules layer4-evolutionary/rules layer2-cognitive/rules \
    "layer1-abstraction/agents/$agent/rules"; do
    _render_policy_directory "$suite/$relative"
  done
  if [[ -n "${AI_SUITE_DOMAIN:-}" ]]; then
    _render_policy_directory "$suite/layer3-registry/domains/$AI_SUITE_DOMAIN/rules"
  else
    for domain in "$suite"/layer3-registry/domains/*; do
      [[ -d "$domain" ]] || continue
      _render_policy_directory "$domain/rules"
    done
  fi
}

generate_markdown_block() {
  local suite="$1" target="$2" agent="$3" start="$4" end="$5"
  [[ -z "$start" ]] || printf '%s\n' "$start"
  if [[ "$agent" != cursor ]]; then
    _render_skill_index "$suite" "$agent" || return
  else
    printf '## AI Suite -- always active\n\nDiscover installed capabilities under %s/skills/.\n' "$target"
  fi
  _render_base_guidance "$target" "$agent" || return
  _render_policies "$suite" "$agent" "$target" || return
  [[ -z "$end" ]] || printf '%s\n' "$end"
}

