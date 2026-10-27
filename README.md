# AI Suite distribution

Portable skills, memory, reflection, and lifecycle tooling for six coding agents.

Requires Bash 3.2 or newer, Python 3.9 or newer, and standard macOS/Linux tools.
Remote operations additionally require SSH and rsync or scp. Domain packs and
private task/evolution history are excluded from this distribution.

```bash
./ai-suite enable --agent codex --scope project --project /path/to/project --dry-run
./ai-suite enable --agent codex --scope project --project /path/to/project
./ai-suite disable --agent codex --scope project --project /path/to/project
bash .ai-suite/layer4-evolutionary/validation/validate-suite.sh
./ai-suite publish
```

Other agents: cursor, claude, opencode, continue, roo-code, or all. Use `--help`
on each command for supported flags. Installs track owned files and preserve
custom artifacts. Edited managed files or ambiguous collisions stop updates
with diagnostics; review and back them up before resolving the conflict.

Evolution collection retains pending two-way merge bundles under
`.ai-suite/layer4-evolutionary/reflection/pending/`. Existing differing files
are preserved. Review incoming changes, validate the resulting suite, and mark
the bundle resolved or discarded before explicitly cleaning it up. Collection
does not update any global agent installation automatically.

Project memory is stored in `.ai-memory/<agent>/`; task history is stored in
`~/.ai-suite/memory/<agent>/tasks/`. Memory APIs are available by sourcing
`.ai-suite/layer2-cognitive/memory/memory.sh`. Masking hides memory contents
from reading and search APIs. Default domain selection retains all available
packs for compatibility; this public distribution has no domain packs.

Source-checkout development tests are separate from runtime validation. All
changes remain uncommitted; review changes and commit manually.
