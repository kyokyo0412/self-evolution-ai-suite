#!/usr/bin/env python3
"""Transactional installation of explicitly owned AI Suite artifacts."""
import argparse
import base64
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import signal
import stat
import sys
import time

from managed_blocks import atomic_write, block_span, checked_path


def digest(data):
    return hashlib.sha256(data).hexdigest()


def artifact_checker(root, options):
    """Allow one pinned global Cursor/Codex directory alias only by opt-in."""
    value = getattr(options, "agent_root_alias", None)
    if value is None:
        return checked_path
    manifests = {".cursor/.ai-suite-manifest.json", ".codex/.ai-suite-manifest.json"}
    if options.manifest not in manifests or root != Path.home().resolve(strict=True):
        raise ValueError("agent root alias requires a global Cursor or Codex installation")
    expected = Path(value)
    if not expected.is_absolute() or not expected.is_dir():
        raise ValueError("agent root alias requires an existing absolute physical directory")
    physical = expected.resolve(strict=True)
    if physical != expected or physical == root or root.is_relative_to(physical):
        raise ValueError("agent root alias requires a separate physical directory")
    aliases = {str(Path(options.manifest).parent): physical}

    def check(target, relative):
        return checked_path(target, relative, aliases)

    check(root, options.manifest)
    return check


def read_manifest(path):
    if not path.exists():
        return {"version": 1, "files": {}, "instruction": None}
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or data.get("version") != 1 or not isinstance(data.get("files"), dict):
        raise ValueError(f"invalid ownership manifest: {path}")
    if "instruction" not in data:
        raise ValueError(f"ownership manifest lacks instruction state: {path}")
    return data


def artifact_files(stage):
    files = {}
    for directory, names, filenames in os.walk(stage, followlinks=False):
        for name in names + filenames:
            path = Path(directory) / name
            if path.is_symlink():
                raise ValueError(f"symlink in staged artifacts: {path}")
        for name in filenames:
            path = Path(directory) / name
            if not path.is_file():
                raise ValueError(f"non-regular staged artifact: {path}")
            files[str(path.relative_to(stage))] = path
    return files


def snapshot(path):
    if not path.exists():
        return None
    if path.is_dir() and not any(path.iterdir()):
        return {"directory": True, "mode": stat.S_IMODE(path.stat().st_mode)}
    if not path.is_file():
        raise ValueError(f"non-regular artifact: {path}")
    return {"data": base64.b64encode(path.read_bytes()).decode("ascii"),
            "mode": stat.S_IMODE(path.stat().st_mode)}


def unchanged(path, expected):
    return (path.is_file() and digest(path.read_bytes()) == expected["sha256"]
            and stat.S_IMODE(path.stat().st_mode) == expected["mode"])


def desired_files(root, stage, old, check=checked_path):
    incoming = artifact_files(stage) if stage else {}
    operations, owned = {}, {}
    for relative in sorted(set(old["files"]) | set(incoming)):
        path = check(root, relative)
        previous = old["files"].get(relative)
        if path.exists() and (previous is None or not unchanged(path, previous)):
            raise ValueError(f"unmanaged collision or user-edited artifact: {path}")
        source = incoming.get(relative)
        if source:
            owned[relative] = {"sha256": digest(source.read_bytes()),
                               "mode": stat.S_IMODE(source.stat().st_mode)}
        if source and path.exists() and owned[relative] == previous:
            continue
        operations[relative] = snapshot(source) if source else None
    return operations, owned


def instruction_plan(root, relative, content, markers, previous, check=checked_path):
    path = check(root, relative)
    empty_directory = path.is_dir() and relative == ".cursorrules" and not any(path.iterdir())
    data = path.read_bytes() if path.exists() and not empty_directory else b""
    span = block_span(data, *markers)
    if span and previous is None:
        raise ValueError(f"legacy managed block has no ownership manifest: {path}")
    if previous and span is None:
        raise ValueError(f"managed instruction block was removed: {path}")
    if span and digest(data[span[0]:span[1]]) != previous["sha256"]:
        raise ValueError(f"user-edited managed instruction block: {path}")
    prefix, suffix = (data[:span[0]], data[span[1]:]) if span else (data, b"")
    preamble = previous.get("preamble", "").encode() if previous else b""
    if span and preamble:
        if not prefix.endswith(preamble):
            raise ValueError(f"user-edited managed instruction preamble: {path}")
        prefix = prefix[:-len(preamble)]
    if span and previous.get("separator") and prefix.endswith(b"\n"):
        prefix = prefix[:-len(previous["separator"].encode())]
    if content is None:
        return prefix + suffix, None
    newline = b"\r\n" if b"\r\n" in data else b"\n"
    block = content.replace(b"\r\n", b"\n").replace(b"\n", newline)
    managed_span = block_span(block, *markers)
    if managed_span is None:
        raise ValueError("generated instruction lacks ownership markers")
    separator = newline if prefix and not prefix.endswith(b"\n") else b""
    return prefix + separator + block + suffix, {
        "path": relative, "sha256": digest(block[managed_span[0]:managed_span[1]]),
        "preamble": block[:managed_span[0]].decode(),
        "separator": separator.decode(),
        "created": previous["created"] if previous else (not path.exists() or empty_directory)}


def add_instruction(root, operations, old, options, check=checked_path):
    previous = old["instruction"]
    if options.action == "remove" and previous is None:
        return None
    relative = previous["path"] if previous else options.instruction
    content = Path(options.block).read_bytes() if options.action == "install" else None
    data, metadata = instruction_plan(root, relative, content,
                                      (options.start.encode(), options.end.encode()), previous, check)
    path = check(root, relative)
    if not data and previous and previous.get("created"):
        operations[relative] = None
    else:
        mode = stat.S_IMODE(path.stat().st_mode) if path.is_file() else 0o644
        operations[relative] = {"data": base64.b64encode(data).decode(), "mode": mode}
    return metadata


def create_parents(path, created):
    pending = []
    while not path.exists():
        pending.append(path)
        path = path.parent
    for directory in reversed(pending):
        directory.mkdir()
        created.append(str(directory))


def apply_operation(path, value):
    if path.is_dir():
        path.rmdir()
    if value is None:
        if path.exists():
            path.unlink()
    elif value.get("directory"):
        if path.is_file():
            path.unlink()
        path.mkdir(mode=value["mode"])
    else:
        atomic_write(path, base64.b64decode(value["data"]), value["mode"])


def prune_empty(root, paths):
    candidates = set()
    for relative in paths:
        directory = (root / relative).parent
        while directory != root:
            candidates.add(directory)
            directory = directory.parent
    for directory in sorted(candidates, key=lambda value: len(value.parts), reverse=True):
        if not directory.is_symlink() and directory.is_dir() and not any(directory.iterdir()):
            directory.rmdir()


def restore(root, journal, check=checked_path):
    for relative, value in reversed(list(journal["before"].items())):
        path = check(root, relative)
        current = snapshot(path)
        if current == value:
            continue
        if "after" in journal and current != journal["after"][relative]:
            raise ValueError(f"concurrent artifact edit prevents automatic rollback; recovery journal retained: {path}")
        if value is not None:
            path.parent.mkdir(parents=True, exist_ok=True)
        apply_operation(path, value)
    prune_empty(root, journal["before"])


def transact(root, manifest, operations, metadata, post_command=None, check=checked_path):
    operations = dict(operations)
    relative_manifest = str(manifest.relative_to(root))
    operations[relative_manifest] = metadata
    before = {relative: snapshot(check(root, relative)) for relative in operations}
    journal_path = manifest.with_name(".ai-suite-transaction.json")
    journal = {"version": 1, "before": before, "after": operations}
    atomic_write(journal_path, json.dumps(journal).encode(), 0o600)
    created = []
    settled = False
    try:
        for relative, value in operations.items():
            path = check(root, relative)
            create_parents(path.parent, created)
            apply_operation(path, value)
        if post_command:
            run_post_command(post_command)
        check(root, relative_manifest)
        settled = True
    except BaseException:
        restore(root, journal, check)
        settled = True
        raise
    finally:
        if settled:
            journal_path.unlink()
        for directory in reversed(created):
            if Path(directory).is_dir() and not any(Path(directory).iterdir()):
                Path(directory).rmdir()
    prune_empty(root, operations)


def run_post_command(command):
    """Keep initialization inside the rollback boundary with bounded child lifetime."""
    from process import run
    old_timeout = os.environ.get("AI_SUITE_TRANSPORT_TIMEOUT")
    os.environ["AI_SUITE_TRANSPORT_TIMEOUT"] = "30"
    try:
        if run(command) != 0:
            raise ValueError("post-install initialization failed; artifact changes rolled back")
    finally:
        signal.signal(signal.SIGTERM, interrupted)
        if old_timeout is None:
            os.environ.pop("AI_SUITE_TRANSPORT_TIMEOUT", None)
        else:
            os.environ["AI_SUITE_TRANSPORT_TIMEOUT"] = old_timeout


@contextmanager
def install_lock(manifest):
    directory = manifest.parent.resolve(strict=True) / ".ai-suite-lock"
    deadline = time.monotonic() + 10
    acquired = False
    try:
        while not acquired:
            try:
                if directory.is_symlink():
                    raise ValueError(f"refusing symlink installation lock: {directory}")
                directory.mkdir()
                (directory / "pid").write_text(str(os.getpid()), encoding="ascii")
                acquired = True
            except FileExistsError:
                clear_stale_lock(directory)
                if time.monotonic() >= deadline:
                    raise ValueError(f"installation locked; inspect before recovery: {directory}")
                time.sleep(0.05)
        yield
    finally:
        if acquired:
            (directory / "pid").unlink()
            directory.rmdir()


def clear_stale_lock(directory):
    """Remove only a lock whose recorded process is definitely gone."""
    owner = directory / "pid"
    try:
        pid = int(owner.read_text(encoding="ascii"))
        if pid <= 0:
            raise ValueError(f"invalid installation lock owner: {directory}")
        os.kill(pid, 0)
    except ProcessLookupError:
        owner.unlink()
        directory.rmdir()
    except FileNotFoundError:
        # Another process may still be recording ownership or releasing its lock.
        return


def process(options):
    root = Path(options.root).resolve(strict=True)
    check = artifact_checker(root, options)
    manifest = check(root, options.manifest)
    manifest.parent.mkdir(parents=True, exist_ok=True)
    try:
        with install_lock(manifest):
            journal = check(root, manifest.with_name(".ai-suite-transaction.json").relative_to(root))
            if journal.exists():
                restore(root, json.loads(journal.read_text()), check)
                journal.unlink()
            old = read_manifest(manifest)
            stage = Path(options.stage) if options.action == "install" else None
            operations, owned = desired_files(root, stage, old, check)
            instruction = add_instruction(root, operations, old, options, check)
            state = {"version": 1, "files": owned, "instruction": instruction}
            metadata = None if options.action == "remove" else {
                "data": base64.b64encode(json.dumps(state, sort_keys=True).encode()).decode(), "mode": 0o600}
            transact(root, manifest, operations, metadata, getattr(options, "post_command", None), check)
    finally:
        if not manifest.parent.is_symlink() and manifest.parent.is_dir() and not any(manifest.parent.iterdir()):
            manifest.parent.rmdir()


def parser():
    arguments = argparse.ArgumentParser(description=__doc__)
    arguments.add_argument("action", choices=("install", "remove"))
    for name in ("root", "manifest", "start", "end"):
        arguments.add_argument(f"--{name}", required=True)
    for name in ("stage", "instruction", "block"):
        arguments.add_argument(f"--{name}")
    arguments.add_argument("--agent-root-alias")
    arguments.add_argument("--post-command", nargs=argparse.REMAINDER)
    return arguments


def interrupted(signum, _frame):
    raise InterruptedError(f"installation interrupted by signal {signum}")


def main():
    for signum in (signal.SIGTERM, signal.SIGHUP, signal.SIGINT):
        signal.signal(signum, interrupted)
    try:
        process(parser().parse_args())
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"[managed-artifacts] ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
