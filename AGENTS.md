# AGENTS

## Purpose
Maintain a minimal WSL-focused repo that tracks Codex history, Codex skills, and X11 setup assets.

## Maintenance rules
- Keep `.gitignore` in allowlist mode. Add new tracked files by whitelisting their paths.
- Update `codex/history.jsonl` by copying from `/home/standard/.codex/history.jsonl`.
- Update `codex/skills/` by copying from `/home/standard/.codex/skills/`.
- Keep `scripts/wsl-x11.sh` and `docs/wsl-x11.md` in sync when changing X11 behavior.
- Make a detailed commit for each significant step (new assets, config changes, or documentation updates).

## X11 behavior
- `scripts/wsl-x11.sh` should only set `DISPLAY` when it is not already set.
- Favor WSL-safe defaults and avoid host-specific hard-coding.
