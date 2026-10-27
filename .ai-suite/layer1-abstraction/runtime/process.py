#!/usr/bin/env python3
"""Run one transport command with a deadline and process-group cleanup."""
import os
import signal
import subprocess
import sys


def signal_group(process, signum):
    try:
        os.killpg(process.pid, signum)
    except ProcessLookupError:
        return


def interrupt(signum, frame):
    raise KeyboardInterrupt


def reap(process):
    signal_group(process, signal.SIGTERM)
    try:
        process.wait(timeout=0.2)
    except subprocess.TimeoutExpired:
        signal_group(process, signal.SIGKILL)
    signal_group(process, signal.SIGKILL)
    process.wait(timeout=3)


def run(argv, **stdio):
    seconds = int(os.environ.get("AI_SUITE_TRANSPORT_TIMEOUT", "120"))
    if not 1 <= seconds <= 3600:
        raise ValueError("transport timeout must be between 1 and 3600 seconds")
    signal.signal(signal.SIGTERM, interrupt)
    signal.signal(signal.SIGHUP, interrupt)
    process = subprocess.Popen(argv, start_new_session=True, **stdio)
    try:
        return process.wait(timeout=seconds)
    except (subprocess.TimeoutExpired, KeyboardInterrupt):
        print("transport interrupted or deadline exceeded", file=sys.stderr)
        return 124
    finally:
        reap(process)


if __name__ == "__main__":
    try:
        sys.exit(run(sys.argv[1:]))
    except (OSError, ValueError) as error:
        print(f"transport: {error}", file=sys.stderr)
        sys.exit(1)
