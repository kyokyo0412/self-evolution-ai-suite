#!/usr/bin/env bash
# Resource discovery and strict copy into disposable staging directories.

_strip_rule_frontmatter() {
  local file="$1" in_frontmatter=false line_num=0 line
  [[ -f "$file" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))
    if [[ "$line_num" -eq 1 && "$line" == "---" ]]; then
      in_frontmatter=true
      continue
    fi
    if $in_frontmatter; then
      [[ "$line" != "---" ]] || in_frontmatter=false
      continue
    fi
    printf '%s\n' "$line"
  done < "$file"
}

_suite_copy_resource() {
  python3 -B "$_AI_SUITE_RUNTIME_DIR/stage_assets.py" "$1" "$2"
}

_suite_resource_directories() {
  local suite="$1" agent="$2" resource="$3" domain relative
  for relative in "layer3-registry/$resource" "layer2-cognitive/$resource" \
    "layer4-evolutionary/$resource" "layer1-abstraction/agents/$agent/$resource"; do
    [[ ! -d "$suite/$relative" ]] || printf '%s\n' "$suite/$relative"
  done
  for domain in "$suite"/layer3-registry/domains/*; do
    [[ -d "$domain/$resource" ]] || continue
    [[ -z "${AI_SUITE_DOMAIN:-}" || "$(basename "$domain")" == "$AI_SUITE_DOMAIN" ]] || continue
    printf '%s\n' "$domain/$resource"
  done
}

_mirror_resources() {
  local suite="$1" dest="$2" agent="$3" resource="$4" source_dir
  mkdir -p "$dest" || return
  while IFS= read -r source_dir; do
    _suite_copy_resource "$source_dir" "$dest" || return
  done < <(_suite_resource_directories "$suite" "$agent" "$resource")
}

_mirror_templates() { _mirror_resources "$1" "$2" "${3:-}" templates; }

_mirror_scripts() {
  local suite="$1" dest="$2" agent="${3:-}" source_file root
  _mirror_resources "$suite" "$dest" "$agent" scripts || return
  for source_file in "$suite/layer2-cognitive/memory/memory.sh" "$suite/layer2-cognitive/memory/core.sh"; do
    _suite_copy_resource "$source_file" "$dest/$(basename "$source_file")" || return
  done
  root=$(cd "$suite/.." && pwd) || return
  for source_file in "$root"/*.sh; do
    [[ -f "$source_file" ]] || continue
    _suite_copy_resource "$source_file" "$dest/$(basename "$source_file")" || return
  done
}

_mirror_skills() {
  python3 -B "$_AI_SUITE_RUNTIME_DIR/stage_assets.py" --skills "$1" "$2" "${3:-}"
}

_mirror_directives() {
  local suite="$1" dest="$2" agent="${3:-}" directory source_file
  mkdir -p "$dest" || return
  for directory in "$suite/layer3-registry/directives" "$suite/layer3-registry/safety" \
    "$suite/layer1-abstraction/agents/$agent/directives"; do
    [[ -d "$directory" ]] || continue
    for source_file in "$directory"/*; do
      [[ -f "$source_file" ]] || continue
      _mirror_policy_file "$source_file" "$dest" "$agent" || return
    done
  done
}

_mirror_policy_file() {
  local source_file="$1" dest="$2" agent="$3" filename
  filename=$(basename "$source_file")
  if [[ "$agent" == cursor ]]; then
    _suite_copy_resource "$source_file" "$dest/$filename"
    return
  fi
  filename=$(printf '%s' "$filename" | sed -E 's/\.(md|mdc)$/.md/')
  if [[ -e "$dest/$filename" ]]; then
    printf '[mirroring] ERROR: policy destination collision: %s\n' "$dest/$filename" >&2
    return 1
  fi
  _strip_rule_frontmatter "$source_file" > "$dest/$filename"
}

_mirror_rules() {
  [[ "${3:-}" != codex ]] || return 0
  _mirror_directives "$@" || return
  local source_dir source_file
  while IFS= read -r source_dir; do
    for source_file in "$source_dir"/*; do
      [[ -f "$source_file" ]] || continue
      _mirror_policy_file "$source_file" "$2" "${3:-}" || return
    done
  done < <(_suite_resource_directories "$1" "${3:-}" rules)
}

_mirror_meta_layers() {
  local suite="$1" meta="$2" relative
  for relative in layer1-abstraction cli layer2-cognitive; do
    _suite_copy_resource "$suite/$relative" "$meta/$relative" || return
  done
  for relative in core directives safety rules templates scripts; do
    [[ ! -d "$suite/layer3-registry/$relative" ]] || \
      _suite_copy_resource "$suite/layer3-registry/$relative" "$meta/layer3-registry/$relative" || return
  done
  for relative in validation merging; do
    _suite_copy_resource "$suite/layer4-evolutionary/$relative" "$meta/layer4-evolutionary/$relative" || return
  done
  _suite_copy_resource "$suite/layer4-evolutionary/reflection/reflection-protocol.md" \
    "$meta/layer4-evolutionary/reflection/reflection-protocol.md" || return
  if [[ -d "$suite/distribution" ]]; then
    _suite_copy_resource "$suite/distribution" "$meta/distribution" || return
  fi
}

_mirror_meta() {
  local suite="$1" meta="$2" root source_file
  _mirror_meta_layers "$suite" "$meta" || return
  _suite_copy_resource "$suite/layer4-evolutionary/validation" "$meta" || return
  _suite_copy_resource "$suite/layer4-evolutionary/reflection/reflection-protocol.md" "$meta/reflection-protocol.md" || return
  root=$(cd "$suite/.." && pwd) || return
  _suite_copy_resource "$root/ai-suite" "$meta/ai-suite" || return
  _suite_copy_resource "$suite/cli" "$meta/scripts" || return
  _suite_copy_resource "$root/ai-suite" "$meta/scripts/ai-suite" || return
  _suite_copy_resource "$suite/layer2-cognitive/memory/core.sh" "$meta/scripts/core.sh" || return
  for source_file in "$root"/*.sh "$root/README.md"; do
    [[ -f "$source_file" ]] || continue
    _suite_copy_resource "$source_file" "$meta/$(basename "$source_file")" || return
  done
}

