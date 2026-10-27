#!/usr/bin/env python3
"""Canonical capability discovery from existing paths and skill frontmatter.

No parallel catalog is maintained. Optional dependencies/references/assets are
JSON arrays, a deliberately small unambiguous subset of YAML frontmatter.
Triggers accept JSON string arrays or indented YAML string lists. Plain list
items must start with a Unicode letter and contain only word characters, spaces,
or . , / ( ) @ + ' -. Reserved YAML scalars require quotes. Use JSON double
quotes or YAML single quotes (doubled apostrophes) for other strings, including
numeric/date-like triggers and literal #. Inline comments are rejected; place
comments on separate lines. This is a supported subset, not a general YAML parser.
"""
import argparse
from dataclasses import asdict, dataclass
import json
import os
from pathlib import Path
import re
import sys

AGENTS = ("cursor", "claude", "opencode", "continue", "roo-code", "codex")
IDENTIFIER = re.compile(r"[a-z0-9][a-z0-9-]{0,63}\Z")


@dataclass(frozen=True)
class Skill:
    name: str
    path: str
    tier: str
    agent: str
    domain: str
    description: str
    dependencies: tuple
    references: tuple
    assets: tuple


def identifier(value):
    if not value:
        raise ValueError("missing 'name:' in frontmatter")
    if len(value) > 64:
        raise ValueError(f"name length {len(value)} > 64")
    if not IDENTIFIER.fullmatch(value):
        raise ValueError(f"name {value!r} must match ^[a-z0-9-]+$ and start with a letter or number")
    return value


def domain_identifier(value):
    if not re.fullmatch(r"[a-z0-9][a-z0-9_-]{0,63}", value):
        raise ValueError(f"invalid domain identifier: {value!r}")
    return value


def directories(root, agent="", domain=None):
    result = [(root / "layer3-registry/core", "core", "", ""),
              (root / "layer4-evolutionary/merging", "merging", "", ""),
              (root / "layer2-cognitive/meta-compiler", "cognitive", "", "")]
    names = AGENTS if agent == "all" else ([agent] if agent else [])
    for name in names:
        if name not in AGENTS:
            raise ValueError(f"unsupported agent: {name}")
        result.append((root / f"layer1-abstraction/agents/{name}/skills",
                       "agent", name, ""))
    domains = root / "layer3-registry/domains"
    if domain:
        domain_identifier(domain)
        if not (domains / domain / "skills").is_dir():
            raise ValueError(f"unknown domain: {domain}")
    selected = [domains / domain] if domain else sorted(domains.glob("*"))
    for path in selected:
        if path.is_dir():
            result.append((path / "skills", "domain", "", path.name))
    return result


def metadata(path):
    lines = path.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "---":
        raise ValueError(f"{path}: first line must be ---")
    try:
        end = lines.index("---", 1)
    except ValueError as error:
        raise ValueError(f"{path}: closing --- not found within first 20 lines") from error
    if end >= 20:
        raise ValueError(f"{path}: closing --- not found within first 20 lines")
    fields = {}
    for line in lines[1:end]:
        match = re.match(r"^([a-z-]+):\s*(.*)$", line)
        if match:
            key, value = match.groups()
            if key in fields:
                raise ValueError(f"{path}: duplicate metadata key {key}")
            fields[key] = value.strip().strip('"')
    if "triggers" in fields:
        fields["triggers"] = parse_triggers(lines[1:end], path)
    return fields, "\n".join(lines[end + 1:])


def trigger_string(value):
    value = value.strip()
    if re.fullmatch(r"'(?:[^']|'')*'", value):
        return value[1:-1].replace("''", "'")
    try:
        return json.loads(value)
    except json.JSONDecodeError:
        if (not re.fullmatch(r"[^\W\d_][\w .,/@+()'-]*", value)
                or value.lower() in ("yes", "no", "on", "off", "~", "null", "true", "false",
                                     ".inf", "+.inf", "-.inf", ".nan")
                or re.fullmatch(r"[-+]?(?:\d[\d_]*(?:\.[\d_]*)?|\.[\d_]+)(?:e[-+]?\d+)?",
                                value, re.I)):
            return None
        return value


def parse_triggers(lines, path):
    start = next(index for index, line in enumerate(lines) if line.startswith("triggers:"))
    inline = lines[start].partition(":")[2].strip()
    if inline:
        try:
            result = json.loads(inline)
        except json.JSONDecodeError as error:
            raise ValueError(f"{path}: triggers must be a nonempty string list") from error
    else:
        result = []
        for line in lines[start + 1:]:
            if line and not line[0].isspace():
                break
            if not line.strip() or line.lstrip().startswith("#"):
                continue
            match = re.fullmatch(r"\s+-\s*(.*)", line)
            if not match:
                raise ValueError(f"{path}: triggers must be a nonempty string list")
            result.append(trigger_string(match.group(1)))
    if not isinstance(result, list) or not result or any(
            not isinstance(item, str) or not item.strip() for item in result):
        raise ValueError(f"{path}: triggers must be a nonempty string list")
    return tuple(result)


def array_field(fields, key, path):
    value = fields.get(key, "[]")
    try:
        result = json.loads(value)
    except json.JSONDecodeError as error:
        raise ValueError(f"{path}: {key} must be a JSON string array") from error
    if not isinstance(result, list) or any(not isinstance(v, str) for v in result):
        raise ValueError(f"{path}: {key} must be a JSON string array")
    return tuple(result)


def skill_record(root, path, tier, agent, domain):
    if path.is_symlink() or not path.resolve().is_relative_to(root.resolve()):
        raise ValueError(f"{path}: skill escapes registry root")
    fields, body = metadata(path)
    name = fields.get("name", "")
    identifier(name)
    expected = path.parent.name if path.name == "SKILL.md" else path.stem
    if name != expected:
        raise ValueError(f"{path}: name must equal filename basename or installed skill directory")
    description = fields.get("description", "")
    if not description:
        raise ValueError(f"{path}: missing 'description:' in frontmatter")
    if len(description) > 1024 or "use when" not in description.lower():
        raise ValueError(f"{path}: description must contain 'Use when' and fit 1024 chars")
    if "triggers" not in fields:
        raise ValueError(f"{path}: missing 'triggers:' in frontmatter")
    if len(body.splitlines()) > 600:
        raise ValueError(f"{path}: body exceeds 600 cap")
    if not re.search(r"^#+.*(negative constraints|safety|rules of engagement)", body, re.I | re.M):
        raise ValueError(f"{path}: missing Negative Constraints or Safety section")
    instruction = r"^#{2,}.*(instructions|workflow|role|context|artifact catalog|operational loop|steps|usage|procedure|operations|execution|protocol)"
    if not re.search(instruction, body, re.I | re.M):
        raise ValueError(f"{path}: missing Instructions or Workflow section")
    optional = [array_field(fields, key, path)
                for key in ("dependencies", "references", "assets")]
    bundled = tuple(str(item.relative_to(path.parent)) for item in
                    (path.parent / "scripts" / name, path.parent / "templates" / name)
                    if item.exists())
    optional[2] = tuple(dict.fromkeys((*optional[2], *bundled)))
    return Skill(name, str(path), tier, agent, domain, description, *optional)


def validate_references(skill, names):
    for dependency in skill.dependencies:
        if dependency not in names:
            raise ValueError(f"{skill.path}: missing dependency {dependency}")
    base = Path(skill.path).parent.resolve()
    for reference in (*skill.references, *skill.assets):
        if not reference or reference == "." or Path(reference).is_absolute() or any(
                component in (".", "..") for component in reference.split("/")):
            raise ValueError(f"{skill.path}: unsafe asset/reference {reference!r}")
        path = base / reference
        if path.is_symlink() or not path.resolve().is_relative_to(base):
            raise ValueError(f"{skill.path}: unsafe asset/reference {reference}")
        if not path.exists():
            raise ValueError(f"{skill.path}: missing asset/reference {reference}")
        if path.is_dir() and any(item.is_symlink() for item in path.rglob("*")):
            raise ValueError(f"{skill.path}: symlink in bundled asset {reference}")


def validate_dependency_cycles(skills):
    graph = {skill.name: skill.dependencies for skill in skills}
    resolved = set()
    for _ in graph:
        ready = {name for name, dependencies in graph.items()
                 if name not in resolved and set(dependencies) <= resolved}
        if not ready:
            break
        resolved.update(ready)
    if len(resolved) != len(graph):
        raise ValueError("cyclic capability dependencies: " + ", ".join(sorted(set(graph) - resolved)))


def discover(root, agent="", domain=None):
    root = Path(root)
    skills = []
    names = set()
    for directory, tier, agent_name, domain_name in directories(root, agent, domain):
        for path in sorted(directory.glob("*.md")):
            skill = skill_record(root, path, tier, agent_name, domain_name)
            if skill.name in names:
                raise ValueError(f"Duplicate skill name found across tiers: {skill.name}")
            names.add(skill.name)
            skills.append(skill)
    for skill in skills:
        validate_references(skill, names)
    validate_dependency_cycles(skills)
    return skills


def validate_targets(targets):
    records = []
    for target in targets:
        target = Path(target)
        if target.is_file():
            paths = [target]
        elif target.is_dir():
            # Supporting reference documents are not independently invocable skills.
            paths = sorted((*target.glob("*.md"), *target.glob("*/SKILL.md")))
        else:
            raise ValueError(f"target not found: {target}")
        records.extend(skill_record(path.parent, path, "standalone", "", "") for path in paths)
    names = {record.name for record in records}
    if len(names) != len(records):
        raise ValueError("Duplicate skill name found across targets")
    for record in records:
        validate_references(record, names)
    validate_dependency_cycles(records)
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("list", "validate", "json", "validate-target"))
    parser.add_argument("suite", type=Path)
    parser.add_argument("targets", nargs="*", type=Path)
    parser.add_argument("--agent", default="")
    parser.add_argument("--domain", default=os.environ.get("AI_SUITE_DOMAIN") or None)
    args = parser.parse_args()
    try:
        skills = (validate_targets([args.suite, *args.targets]) if args.command == "validate-target"
                  else discover(args.suite, args.agent, args.domain))
        if args.command == "list":
            print("\n".join(skill.path for skill in skills))
        elif args.command == "json":
            print(json.dumps([asdict(skill) for skill in skills], indent=2))
        else:
            print(f"[registry] {len(skills)} skills validated; references and IDs valid")
    except (OSError, UnicodeError, ValueError) as error:
        print(f"[registry] ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
