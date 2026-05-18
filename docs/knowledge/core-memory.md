# Core Memory

This file stores durable maintenance notes for automation and contributors.

## Recent-change audit workflow

- Scan recent commits by date window:
  - `git log --since='<last_run_iso>' --name-status --pretty='format:=== %H %ad %s' --date=iso-strict master`
- Scan a short fallback window when no commits appear since the last run:
  - `git log --since='24 hours ago' --name-status --pretty='format:=== %H %ad %s' --date=iso-strict master`
- Run a broader periodic audit window:
  - `git log --since='7 days ago' --name-status --pretty='format:=== %H %ad %s' --date=iso master`
- Inspect a single commit with minimal context for evidence-first triage:
  - `git show --unified=0 --pretty=format:'=== %H %s' <commit_sha> -- <path...>`
- Verify post-merge CI for a merge commit on `master`:
  - `gh run list --branch master --commit "<merge_sha>" --json databaseId,displayTitle,status,conclusion,url --limit 20`

## Dead-code evidence workflow

- Only mark code dead after zero non-test references:
  - `rg -n '<symbol>' . --glob '!**/*test*' --glob '!**/*spec*'`

## CI architecture workflow

- Check whether a base image tag is multi-arch before enabling `linux/arm64`:
  - `docker buildx imagetools inspect <base-image:tag>`
- Keep `gcloud/*` and `debezium/*` on `linux/amd64` in generated CI while their upstream base tags publish single-arch manifests.
- Keep `rust/sccache*` tags (`sccache`, `sccache-server`, `sccache-scheduler`) on `linux/amd64` by tag override because `sccache-dist` fails to compile on arm64 (`Distributed compilation is only supported on Linux/x86_64 and FreeBSD`).
- If default uv cache path is not writable in sandbox/worktree runs, use:
  - `UV_CACHE_DIR=$PWD/.uv-cache uv run python gen.py`

## Repo notes

- `AGENTS.md` is a symlink to `CLAUDE.md`; update `CLAUDE.md` for shared instructions.
- Keep maintenance knowledge in this file and avoid dated review artifacts.
- If `.git/worktrees/.../*.lock` blocks git writes in a linked worktree, continue from the canonical checkout and keep the same branch.
- If linked-worktree git metadata blocks fetch writes (`.../FETCH_HEAD: Operation not permitted`), rerun fetch from the canonical checkout.
- If a linked worktree opens in detached `HEAD`, create a branch from `master` before editing.
- If the since-last-run commit window only changes docs/knowledge files, report no functional bug/perf regression findings and skip code fixes.
- To confirm detached `HEAD` state and branch ownership across linked worktrees:
  - `git worktree list --porcelain`
- To fetch safely from the canonical checkout when linked-worktree metadata writes fail:
  - `git -C <canonical_checkout_path> fetch origin --prune`
- To create/switch feature branches from canonical checkout when linked-worktree HEAD writes fail:
  - `git -C <canonical_checkout_path> switch -c <branch_name>`
