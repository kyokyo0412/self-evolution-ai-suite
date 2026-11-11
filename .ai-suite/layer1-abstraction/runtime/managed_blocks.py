#!/usr/bin/env python3
"""Lossless managed instruction blocks and atomic same-directory writes."""
import os
from pathlib import Path
import stat
import sys
import tempfile


def validate_root_aliases(root, aliases):
    """Recheck explicitly pinned directory aliases before every managed access."""
    for relative, expected in aliases.items():
        alias = Path(root) / relative
        try:
            matches = (alias.is_symlink() and expected.is_dir()
                       and alias.resolve(strict=True) == expected)
        except (OSError, RuntimeError) as error:
            raise ValueError(f"unresolvable agent root alias: {alias}") from error
        if not matches:
            raise ValueError(f"agent root alias changed or mismatched: {alias}")


def checked_path(root, relative, aliases=None):
    """Return a lexical path, rejecting symlinks except explicitly pinned roots."""
    root = Path(root)
    aliases = aliases or {}
    validate_root_aliases(root, aliases)
    relative = Path(relative)
    if relative.is_absolute() or not relative.parts or ".." in relative.parts:
        raise ValueError(f"unsafe relative artifact path: {relative}")
    current = Path(root)
    for part in relative.parts:
        current = current / part
        if current.is_symlink() and str(current.relative_to(root)) not in aliases:
            raise ValueError(f"refusing symlink artifact: {current}")
    return current


def checked_absolute_path(path):
    """Allow platform-owned root aliases, but reject user-controlled symlink parents."""
    path = Path(path).absolute()
    relative = path.relative_to(path.anchor)
    first, *remaining = relative.parts
    base = Path(path.anchor) / first
    if first in ("tmp", "var", "etc") and base.is_symlink():
        return checked_path(base.resolve(strict=True), Path(*remaining))
    return checked_path(path.anchor, relative)


def block_span(data, start, end):
    """Return one complete block's byte span; reject ambiguous markers."""
    starts, ends, offset = [], [], 0
    for line in data.splitlines(keepends=True):
        marker = line.rstrip(b"\r\n")
        if marker == start:
            starts.append(offset)
        if marker == end:
            ends.append(offset + len(line))
        offset += len(line)
    if not starts and not ends:
        return None
    if len(starts) != 1 or len(ends) != 1 or starts[0] >= ends[0]:
        raise ValueError("malformed or ambiguous managed instruction markers")
    return starts[0], ends[0]


def atomic_write(path, data, mode=None):
    """Replace one regular file atomically, retaining its existing permissions."""
    path = Path(path)
    if path.is_symlink() or (path.exists() and not path.is_file()):
        raise ValueError(f"refusing non-regular artifact: {path}")
    if mode is None:
        mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o644
    descriptor, temporary = tempfile.mkstemp(prefix=".ai-suite-write-", dir=path.parent)
    try:
        with os.fdopen(descriptor, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
            os.fchmod(stream.fileno(), mode)
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def remove_block(path, start, end):
    path = checked_absolute_path(path)
    if not path.exists():
        return
    data = path.read_bytes()
    span = block_span(data, start.encode(), end.encode())
    if span is not None:
        atomic_write(path, data[:span[0]] + data[span[1]:])


def main():
    try:
        if len(sys.argv) != 4:
            raise ValueError("usage: managed_blocks.py FILE START_MARKER END_MARKER")
        if sys.argv[1] == "--check-path":
            checked_path(Path(sys.argv[2]).resolve(strict=True), sys.argv[3])
        else:
            remove_block(*sys.argv[1:])
    except (OSError, ValueError) as error:
        print(f"[managed-block] ERROR: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
