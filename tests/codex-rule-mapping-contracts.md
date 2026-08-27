# Codex Rule Prompt Mapping Contracts & Transformation Specification

## 1. Overview
The Codex agent requires instructions and rules to be presented as structured prompt Markdown rather than raw IDE configuration files with YAML headers.

## 2. Transformation Pipeline

### 2.1 Frontmatter Stripping (`_strip_rule_frontmatter`)
- Input: Any `.md` or `.mdc` rule file.
- Output: Standard Markdown content with any leading `---` frontmatter block removed.

### 2.2 Inlining into `AGENTS.md` (`generate_markdown_block`)
- Inlines directives, safety guardrails, core rules, and active domain rules as standard Markdown sections.
- Guaranteed: No `---`, `globs:`, `alwaysApply:` tags present inside the inlined rule sections in `AGENTS.md`.

### 2.3 Rule File Mirroring (`_mirror_rules`)
- For non-Cursor agents (`codex`, `claude`, etc.):
  - Converts all `.mdc` rule files into `.md` files in the destination directory.
  - Strips YAML frontmatter from mirrored `.md` files.
  - Includes directives, safety, core, and domain rules.

### 2.4 Dynamic Assertions
- All test counts and scenario assertions must be dynamic, without hardcoded counts.
