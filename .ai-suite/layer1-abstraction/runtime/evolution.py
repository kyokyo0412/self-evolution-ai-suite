#!/usr/bin/env python3
"""Retain incoming evolution as durable, idempotent two-way merge bundles."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import signal
import sys
import tempfile

from registry import AGENTS, discover
from managed_artifacts import install_lock, interrupted

PENDING = Path("layer4-evolutionary/reflection/pending")
DATA_PREFIXES = ("memory/", ".ai-memory/", str(PENDING) + "/")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None


def contained(root, relative):
    path = root / relative
    if not path.resolve().is_relative_to(root.resolve()):
        raise ValueError(f"path escapes suite: {relative}")
    for part in (path, *path.parents):
        if part == root:
            break
        if part.is_symlink():
            raise ValueError(f"symlink in evolution path: {relative}")
    return path


def incoming_files(root):
    count = 0
    for directory, dirs, files in os.walk(root, followlinks=False):
        for name in (*dirs, *files):
            if (Path(directory) / name).is_symlink():
                raise ValueError("symlinks are not accepted in incoming evolution")
        for name in sorted(files):
            path = Path(directory) / name
            relative = path.relative_to(root)
            if str(relative).startswith(DATA_PREFIXES):
                continue
            count += 1
            if count > 10000 or path.stat().st_size > 16 * 1024 * 1024:
                raise ValueError("incoming evolution exceeds bounded file/size limit")
            yield relative, path


def differences(suite, incoming):
    records = []
    for relative, path in sorted(incoming_files(incoming)):
        local = contained(suite, relative)
        local_hash, incoming_hash = digest(local), digest(path)
        if local_hash != incoming_hash:
            records.append(dict(path=str(relative), local_hash=local_hash,
                                incoming_hash=incoming_hash, base_hash=None,
                                state="pending" if local.exists() else "new"))
    return records


def atomic_json(path, content):
    descriptor, temporary = tempfile.mkstemp(prefix=".manifest-", dir=path.parent)
    try:
        with os.fdopen(descriptor, "w") as handle:
            json.dump(content, handle, indent=2)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def retain_bundle(suite, incoming, origin, records):
    identity = hashlib.sha256(json.dumps([origin, records], sort_keys=True).encode()).hexdigest()[:24]
    parent = contained(suite, PENDING)
    parent.mkdir(parents=True, exist_ok=True)
    bundle = contained(suite, PENDING / identity)
    if bundle.exists():
        return bundle
    with tempfile.TemporaryDirectory(prefix=".incoming-", dir=parent) as temporary:
        stage = Path(temporary) / "bundle"
        stage.mkdir()
        for record in records:
            target = stage / "incoming" / record["path"]
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(incoming / record["path"], target)
        manifest = dict(version=1, origin=origin, files=records,
                        comparison="two-way", status="pending",
                        created=datetime.now(timezone.utc).isoformat())
        atomic_json(stage / "manifest.json", manifest)
        (stage / "README.md").write_text(
            "# Pending evolution\n\nReview manifest.json and incoming/. Existing local files "
            "were preserved. No merge base is available. Validate reviewed changes before "
            "applying; mark manifest status resolved or discarded before explicit cleanup.\n")
        try:
            stage.rename(bundle)
        except FileExistsError:
            if not (bundle / "manifest.json").is_file():
                raise
    return bundle


def validate_new(suite, incoming, records):
    allowed = {"cli", "layer1-abstraction", "layer2-cognitive", "layer3-registry",
               "layer4-evolutionary", "distribution", "tests"}
    if any(Path(record["path"]).parts[0] not in allowed for record in records):
        raise ValueError("incoming paths do not use the supported suite layout")
    with tempfile.TemporaryDirectory(prefix="suite-evolution-validation-") as temporary:
        candidate = Path(temporary) / ".ai-suite"
        shutil.copytree(suite, candidate, ignore=shutil.ignore_patterns("pending"))
        for record in records:
            if record["state"] == "new":
                target = candidate / record["path"]
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(incoming / record["path"], target)
        discover(candidate, "all")


def promote_new(suite, bundle, manifest):
    applied = []
    try:
        for record in manifest["files"]:
            if record["state"] != "new":
                continue
            target = contained(suite, record["path"])
            target.parent.mkdir(parents=True, exist_ok=True)
            source = contained(bundle / "incoming", Path(record["path"]))
            if digest(source) != record["incoming_hash"]:
                raise ValueError(f"retained input was modified: {record['path']}")
            descriptor, temporary = tempfile.mkstemp(prefix=".evolution-", dir=target.parent)
            os.close(descriptor)
            try:
                shutil.copy2(source, temporary)
                os.link(temporary, target)
                applied.append((target, record))
            finally:
                os.unlink(temporary)
        for _, record in applied:
            record["state"] = "applied"
    except BaseException:
        for path, record in reversed(applied):
            if digest(path) == record["incoming_hash"]:
                path.unlink()
        raise


def collect_locked(suite, incoming, origin):
    records = differences(suite, incoming)
    if not records:
        print(f"No changes detected from {origin}")
        return
    bundle = retain_bundle(suite, incoming, origin, records)
    manifest_path = contained(bundle, Path("manifest.json"))
    manifest = json.loads(manifest_path.read_text())
    try:
        validate_new(suite, incoming, records)
        promote_new(suite, bundle, manifest)
    except (OSError, ValueError) as error:
        manifest["validation_error"] = str(error)
        atomic_json(manifest_path, manifest)
        raise ValueError(f"incoming changes retained at {bundle}: {error}") from error
    manifest["status"] = "pending" if any(r["state"] == "pending" for r in manifest["files"]) else "applied"
    atomic_json(manifest_path, manifest)
    report_dir = contained(suite, Path("layer4-evolutionary/reflection/evolutions"))
    report_dir.mkdir(parents=True, exist_ok=True)
    report = report_dir / f"EVOLUTION-{bundle.name}.md"
    report.write_text(f"# Evolution from {origin}\n\nBundle: `{bundle}`\n\n"
                      f"Status: {manifest['status']}; comparison: two-way, base unavailable.\n\n"
                      + "\n".join(f"- {r['state']}: `{r['path']}`" for r in manifest["files"]) + "\n")
    print(f"Evolution report written: {report}\nPending merge workspace: {bundle}")
    print("Review retained incoming files before applying conflicts. No global agent was modified.")


def collect(suite, incoming, origin):
    if not differences(suite, incoming):
        print(f"No changes detected from {origin}")
        return
    parent = contained(suite, PENDING)
    parent.mkdir(parents=True, exist_ok=True)
    with install_lock(parent / "collection.json"):
        collect_locked(suite, incoming, origin)


def local_snapshot(suite, home, destination, selected):
    for agent in (AGENTS if selected == "all" else (selected,)):
        mapping = {s.name: Path(s.path).relative_to(suite) for s in discover(suite, agent)}
        directory = ".config/opencode" if agent == "opencode" else "." + ("roo" if agent == "roo-code" else agent)
        for path in sorted((home / directory / "skills").glob("*/SKILL.md")):
            contained(home, path.relative_to(home))
            relative = mapping.get(path.parent.name, Path(f"layer1-abstraction/agents/{agent}/skills/{path.parent.name}.md"))
            target = destination / relative
            if target.exists() and digest(target) != digest(path):
                raise ValueError(f"divergent local agents share capability {relative}; collect separately")
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, target)


def main():
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGHUP, interrupted)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("collect", "snapshot"))
    parser.add_argument("suite", type=Path)
    parser.add_argument("directory", type=Path)
    parser.add_argument("--origin", default="local")
    parser.add_argument("--agent", choices=(*AGENTS, "all"), default="all")
    args = parser.parse_args()
    try:
        if args.command == "snapshot":
            local_snapshot(args.suite, Path.home(), args.directory, args.agent)
        else:
            collect(args.suite, args.directory, args.origin)
    except (OSError, UnicodeError, ValueError) as error:
        print(f"evolve: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
