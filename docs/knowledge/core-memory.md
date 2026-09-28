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

## Published-vs-master gate (`published` job, issue #97)

- Nothing else compares the registry to the tree, so a run that starts before a commit lands and finishes after it publishes the older tree while every check stays green. The `published` job closes that hole.
- Check the registry against master locally before trusting a green run:
  - `./tools/collect_commit_shas.sh && python3 tools/verify_published.py --tree tree.txt --commits commit-shas.txt`
- Failure classes: `MISSING` (tag absent), `STALE` (built from a commit older than the one that last touched its directory), `UNKNOWN` (unreadable, or no revision label — fails closed). Exit 1 for any, exit 2 for bad input or unreachable registry.
- Staleness is decided with `git merge-base --is-ancestor`, never by SHA equality or timestamps. Equality is wrong because a commit that regenerates `ci.yaml` is in every family's paths filter and stamps all 68 images; timestamps are wrong because an overlapping run stamps images *newer* than a commit while building the *older* tree.
- The comparison uses the OCI `org.opencontainers.image.revision` label in the amd64 config blob, so it costs no extra round trip and works with anonymous ghcr.io pulls.
- The job runs `if: always()` so a failed build still gets caught, and skips on `pull_request`. It needs a full clone (`fetch-depth: 0`) and `ref: ${{ github.event.after }}`.
- Self-test the gate before trusting it: `./tools/test_verify_published.sh` (offline) and `--live` (hits ghcr.io). Offline cases stub the registry and git probes, so they are deterministic and CI-safe.
- `collect_commit_shas.sh` writes `tree.txt`, `dirs.txt`, and `commit-shas.txt` into the repo root (gitignored) because `$TMPDIR` is not always writable in Actions.

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

## Supply Chain Security: GitHub Actions Pinning (2026-06-10)

- **Incident:** In March 2026, `aquasecurity/trivy-action` had tags force-pushed with malicious code across 75 versions.
- **Mitigation:** Always pin actions to specific version tags (e.g., `@v0.36.0`). Prefer commit SHAs for critical pipelines.
- **Pattern:** Two-phase Trivy scan — first run generates report (exit-code: 0, always succeeds), second run fails on HIGH/CRITICAL with `skip-setup-trivy: true` to avoid re-downloading.
- **Current version:** `aquasecurity/trivy-action@v0.36.0`
