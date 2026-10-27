#!/usr/bin/env python3
"""Install shell hooks through the same owned, lossless artifact transaction."""
import argparse
from pathlib import Path
import shlex
import signal
import sys
import tempfile

import managed_artifacts

START = "### AI SUITE AUTO-ENABLE HOOK START ###"
END = "### AI SUITE AUTO-ENABLE HOOK END ###"


def hook_body(kind, launcher):
    command = shlex.quote(str(launcher))
    common = [START, "__ai_suite_chpwd() {",
              "  [[ -d ./.git ]] || return 0",
              "  [[ -d ./.ai-suite || -f ./ai-suite ]] && return 0",
              f"  if [[ -x {command} ]]; then",
              f'    command bash {command} enable --scope project --project "$PWD" >/dev/null 2>&1',
              "  fi", "}"]
    if kind == "zsh":
        common += ["typeset -ga chpwd_functions", "chpwd_functions+=(__ai_suite_chpwd)"]
    else:
        common += ["__ai_suite_prompt() {",
                   '  if [[ "$PWD" != "${__AI_SUITE_LAST_PWD:-}" ]]; then',
                   '    __AI_SUITE_LAST_PWD="$PWD"', "    __ai_suite_chpwd", "  fi", "}",
                   'PROMPT_COMMAND="__ai_suite_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"']
    return "\n".join([*common, END, ""])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("install", "remove"))
    parser.add_argument("kind", choices=("bash", "zsh"))
    parser.add_argument("rc", type=Path)
    parser.add_argument("launcher", type=Path)
    args = parser.parse_args()
    signal.signal(signal.SIGTERM, managed_artifacts.interrupted)
    try:
        with tempfile.TemporaryDirectory(prefix="suite-hook-") as temporary:
            root = Path(temporary)
            (root / "stage").mkdir()
            block = root / "block"
            block.write_text(hook_body(args.kind, args.launcher))
            options = managed_artifacts.parser().parse_args([
                args.action, "--root", str(args.rc.parent),
                "--manifest", f".ai-suite/hooks/{args.kind}/manifest.json",
                "--start", START, "--end", END, "--instruction", args.rc.name,
                "--stage", str(root / "stage"), "--block", str(block)])
            managed_artifacts.process(options)
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"shell hook: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
