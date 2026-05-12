# Core Memory

This file stores durable maintenance notes for automation and contributors.

## Recent-change audit workflow

- Scan recent commits by date window:
  - `git log --since='<last_run_iso>' --name-status --pretty='format:=== %H %ad %s' --date=iso-strict master`
- Scan fallback window when no new commits are found:
  - `git log --since='7 days ago' --name-status --pretty='format:=== %H %ad %s' --date=iso master`

## Dead-code evidence workflow

- Only mark code dead after zero non-test references:
  - `rg -n '<symbol>' . --glob '!**/*test*' --glob '!**/*spec*'`

## Repo notes

- `AGENTS.md` is a symlink to `CLAUDE.md`; update `CLAUDE.md` for shared instructions.
- Keep maintenance knowledge in this file and avoid dated review artifacts.
