#!/usr/bin/env python3
"""Build complete public packages from a declared, validated artifact set."""
import argparse
import gzip
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import signal
import sys
import tarfile
import tempfile

from registry import AGENTS, discover
from managed_artifacts import interrupted


def context(origin):
    candidate = origin.parent.parent
    if (candidate / ".ai-suite").is_dir():
        return candidate / ".ai-suite", candidate / "ai-suite", candidate
    meta = origin.parent if origin.name in ("scripts", "cli") else origin.parent.parent
    if (meta / "layer1-abstraction").is_dir():
        launcher = meta / "ai-suite"
        if not launcher.is_file():
            launcher = meta / "scripts/ai-suite"
        return meta, launcher, Path.cwd()
    raise ValueError(f"cannot locate complete source/installed suite from {origin}")


def source_path(suite, relative):
    path = suite / relative
    if Path(relative).is_absolute() or not path.resolve().is_relative_to(suite.resolve()):
        raise ValueError(f"artifact escapes source: {relative}")
    if not path.exists() or path.is_symlink():
        raise ValueError(f"missing or symlinked required artifact: {relative}")
    return path


def copy_artifact(suite, stage, relative):
    source = source_path(suite, relative)
    destination = stage / ".ai-suite" / relative
    destination.parent.mkdir(parents=True, exist_ok=True)
    if source.is_dir():
        for path in source.rglob("*"):
            if path.is_symlink():
                raise ValueError(f"symlink in package artifact: {path}")
        shutil.copytree(source, destination,
                        ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
    else:
        shutil.copy2(source, destination)


def stage_package(suite, launcher, stage):
    manifest = json.loads(source_path(suite, "distribution/package.json").read_text())
    for relative in (*manifest["directories"], *manifest["files"]):
        copy_artifact(suite, stage, relative)
    if not launcher.is_file() or launcher.is_symlink():
        raise ValueError("required launcher is missing or symlinked")
    shutil.copy2(launcher, stage / "ai-suite")
    shutil.copy2(suite / "distribution/README.md", stage / "README.md")
    for relative in manifest["required"]:
        source_path(stage / ".ai-suite", relative)
    for agent in AGENTS:
        source_path(stage / ".ai-suite", f"layer1-abstraction/agents/{agent}/adapter.sh")
    discover(stage / ".ai-suite", "all")


def verify_public(stage):
    restricted = re.compile(b"vm" + b"ware|broad" + b"com", re.I)
    hashes = {}
    for path in sorted(stage.rglob("*")):
        if not path.is_file():
            continue
        relative = str(path.relative_to(stage))
        if path.stat().st_size > 16 * 1024 * 1024 or len(hashes) >= 10000:
            raise ValueError("package exceeds bounded artifact size/count")
        content = path.read_bytes()
        if restricted.search(content):
            raise ValueError(f"restricted domain content in required artifact: {relative}; fix source or manifest")
        hashes[relative] = hashlib.sha256(content).hexdigest()
    (stage / "package-manifest.json").write_text(json.dumps(
        dict(version=1, files=hashes), indent=2) + "\n")


def write_archive(stage, destination):
    descriptor, temporary = tempfile.mkstemp(prefix=".suite-package-", dir=destination.parent)
    try:
        with os.fdopen(descriptor, "wb") as output:
            with gzip.GzipFile(filename="", fileobj=output, mode="wb", mtime=0) as compressed:
                with tarfile.open(fileobj=compressed, mode="w|") as archive:
                    for path in [stage, *sorted(stage.rglob("*"))]:
                        name = "ai-suite-package" + ("/" + str(path.relative_to(stage)) if path != stage else "")
                        info = archive.gettarinfo(str(path), arcname=name)
                        info.uid = info.gid = info.mtime = 0
                        info.uname = info.gname = ""
                        if path.is_file():
                            with path.open("rb") as handle:
                                archive.addfile(info, handle)
                        else:
                            archive.addfile(info)
        os.replace(temporary, destination)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def main():
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGHUP, interrupted)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("origin", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    try:
        suite, launcher, destination = context(args.origin)
        with tempfile.TemporaryDirectory(prefix="suite-package-") as temporary:
            stage = Path(temporary) / "package"
            stage.mkdir()
            stage_package(suite, launcher, stage)
            verify_public(stage)
            if args.dry_run:
                print("[DRY-RUN] package validated; no archive was written.")
                return 0
            output = destination / "ai-suite-package.tar.gz"
            write_archive(stage, output)
        print(f"Package created successfully: {output}")
    except (OSError, UnicodeError, ValueError, KeyError) as error:
        print(f"publish: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
