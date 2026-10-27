#!/usr/bin/env python3
"""Stage, validate and promote domain installations without overwriting data."""
import argparse
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile

from registry import discover, domain_identifier
from managed_artifacts import install_lock, interrupted
from managed_blocks import checked_path
from process import run


def execute(*args):
    # Git diagnostics may contain URL credentials. Report status without raw output.
    code = run(list(args), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if code:
        raise ValueError(f"git domain operation failed with exit status {code}")


def domain_sources(repository, domain):
    directory = checked_path(repository.resolve(strict=True), ".ai-suite/layer3-registry/domains")
    paths = [directory / domain] if domain else sorted(directory.glob("*"))
    if not paths:
        raise ValueError("repository has no domain packs")
    for path in paths:
        domain_identifier(path.name)
        if not path.is_dir() or path.is_symlink():
            raise ValueError(f"invalid or missing domain pack: {path.name}")
        if any(item.is_symlink() for item in path.rglob("*")):
            raise ValueError(f"domain pack contains symlinks: {path.name}")
    return paths


def promote(suite, sources):
    destination = suite / "layer3-registry/domains"
    if destination.is_symlink() or not destination.resolve().is_relative_to(suite.resolve()):
        raise ValueError("domain destination escapes suite")
    for path in sources:
        if (destination / path.name).exists():
            raise ValueError(f"domain already exists; preserve and review before replacement: {path.name}")
    with tempfile.TemporaryDirectory(prefix=".domain-stage-", dir=suite.parent) as temporary:
        candidate = Path(temporary) / ".ai-suite"
        shutil.copytree(suite, candidate, ignore=shutil.ignore_patterns("pending"))
        for path in sources:
            shutil.copytree(path, candidate / "layer3-registry/domains" / path.name)
        discover(candidate, "all")
        destination.mkdir(parents=True, exist_ok=True)
        with install_lock(destination / ".domain-install.json"):
            promote_paths(candidate, destination, sources)


def promote_paths(candidate, destination, sources):
    applied = []
    try:
        for path in sources:
            target = destination / path.name
            if target.exists():
                raise ValueError(f"concurrent domain install: {path.name}")
            (candidate / "layer3-registry/domains" / path.name).rename(target)
            applied.append(target)
    except BaseException:
        for path in reversed(applied):
            shutil.rmtree(path)
        raise


def install(suite, url, domain):
    if not url or url.startswith("-") or "\n" in url or "\r" in url:
        raise ValueError("invalid repository URL")
    if domain:
        domain_identifier(domain)
    with tempfile.TemporaryDirectory(prefix="suite-domain-clone-") as temporary:
        repository = Path(temporary) / "repository"
        execute("git", "clone", "--depth", "1", "--filter=blob:none", "--sparse", "--", url, str(repository))
        target = ".ai-suite/layer3-registry/domains" + ("/" + domain if domain else "")
        execute("git", "-C", str(repository), "sparse-checkout", "set", target)
        promote(suite, domain_sources(repository, domain))
    print("Domain install complete; validated before promotion.")


def main():
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGHUP, interrupted)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("suite", type=Path)
    parser.add_argument("url")
    parser.add_argument("--domain", default="")
    args = parser.parse_args()
    try:
        install(args.suite, args.url, args.domain)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print(f"domain install: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
