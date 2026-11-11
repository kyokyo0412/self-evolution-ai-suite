# Codex Task Index

## 2026-10-27 - Enable ai-suite globally for codex (local + remote sunlinux)
- Request: `enable AI suite for remote server sunlinux and local machine for codex globally`.
- Status: VERIFIED + HANDOFF. Session sandboxed for both writes to `~/.codex` and outbound network (ssh 10.0.0.104 EPERM); deploys finished by user in own shell: `bash ai-suite enable --scope global --agent codex` (local) + `bash ai-suite enable --scope remote --host sunlinux --agent codex` (remote).
- Key facts:
  - HEAD `6a90a7b` (20 skills incl. new `ai-review-bot`); working tree clean. `.ai-memory/` wiped in the Oct refactor; this file re-creates it.
  - Live `~/.codex` (2026-09-25) byte-identical to `c6a62e8` for all 20 skills -> purely stale; re-enable lossless, applies only the `6a90a7b` delta.
  - New lifecycle (runtime/lifecycle.sh + managed_blocks.py): ownership-managed - uninstall removes ONLY owned artifacts; unowned skills and legacy `~/.codex/.codexrules` retained (behavior-tested in scratch HOME). Block now lands in `~/.codex/AGENTS.md` (sentinel pair); `.codexrules` stays 0-byte legacy.
  - Remote pipeline (runtime/transport.sh): `mkdir -p ~/.ai-suite-deploy` + `rsync -az` (NO --delete; legacy nested cleanup removed) + remote `enable --scope global`. `--dry-run` still does NOT gate remote scope - never a safe preview there.
  - Staging proof: scratch-HOME local + scratch-deploy remote enables both passed validator + registry (20 skills, sentinel pair, skill index = 20).
- Evolution: none in-repo (memory re-created only).
