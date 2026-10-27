#!/usr/bin/env python3
"""Copy declared resources to staging without hiding failures or collisions."""
import os
from pathlib import Path
import shutil
import sys

from registry import array_field, discover, metadata


def copy_file(source, destination):
    if source.is_symlink() or not source.is_file():
        raise ValueError(f"unsupported resource: {source}")
    if destination.exists():
        if not destination.is_file() or destination.read_bytes() != source.read_bytes():
            raise ValueError(f"resource destination collision: {destination}")
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)


def copy_resource(source, destination):
    if source.is_symlink():
        raise ValueError(f"symlink resource: {source}")
    if source.is_file():
        copy_file(source, destination)
        return
    if not source.is_dir():
        raise ValueError(f"missing resource: {source}")
    destination.mkdir(parents=True, exist_ok=True)
    for directory, names, filenames in os.walk(source, followlinks=False):
        for name in names:
            child = Path(directory) / name
            if child.is_symlink():
                raise ValueError(f"symlink resource directory: {child}")
        for name in filenames:
            child = Path(directory) / name
            copy_file(child, destination / child.relative_to(source))


def copy_skills(suite, destination, agent):
    for skill in discover(suite, agent, os.environ.get("AI_SUITE_DOMAIN") or None):
        source = Path(skill.path)
        target = destination / skill.name
        copy_file(source, target / "SKILL.md")
        for resource in ("scripts", "templates"):
            conventional = source.parent / resource / skill.name
            if conventional.exists():
                copy_resource(conventional, target / resource)
        fields, _ = metadata(source)
        declared = (*array_field(fields, "assets", source),
                    *array_field(fields, "references", source))
        for relative in declared:
            path = Path(relative)
            if path.is_absolute() or not path.parts or ".." in path.parts:
                raise ValueError(f"resource must have a contained relative path: {relative}")
            copy_resource(source.parent / path, target / path)


def main():
    try:
        if len(sys.argv) == 5 and sys.argv[1] == "--skills":
            copy_skills(Path(sys.argv[2]), Path(sys.argv[3]), sys.argv[4])
        elif len(sys.argv) != 3:
            raise ValueError("usage: stage_assets.py SOURCE DESTINATION")
        else:
            copy_resource(Path(sys.argv[1]), Path(sys.argv[2]))
    except (OSError, ValueError) as error:
        print(f"[stage-assets] ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
