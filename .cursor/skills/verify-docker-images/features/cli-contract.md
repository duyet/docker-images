# --dry-run / CLI contract

`gen.py --dry-run` prints the workflow it *would* write, and `gen.py --help`
describes the flags. The contract that matters: **the preview is byte-identical
to the file a real run produces.** This is the entry point that catches "I added
an image directory and forgot to regenerate" — the failure with no error message
anywhere in the repo.

## Sub-features

- `cli-help-exit` `gen.py --help` exits 0, prints `usage:`, and documents `--dry-run`.
- `cli-help-quiet` `--help` writes nothing to stderr.
- `dry-run-no-write` `--dry-run` writes no file: stdout only, and `ci.yaml` and `README.md` are untouched.
- `dry-run-byte-exact` `--dry-run` stdout equals the committed `.github/workflows/ci.yaml` byte for byte, including the trailing newline.
- `dry-run-in-sync` that equality holds after every generator-affecting change. `doctor workflow_in_sync` is the check; `drive dry-run-sync` is the recorded proof.
- `cli-preview-contract` the preview is written with `sys.stdout.write`, not `print`, so it cannot gain a newline the write path does not.

## How to get to it (user POV)

- Preview the workflow without writing: `uv run python gen.py --dry-run`.
- Discover the flags: `uv run python gen.py --help`.
- Commit the real thing: `uv run python gen.py`.
- Check whether the repo is in sync at any time: `verify-docker-images doctor`.

## Driving it with verify-docker-images

Preconditions:

- `verify-docker-images launch` has run and `.run/instance.json` exists.
- `verify-docker-images doctor` exits 0.

- **Check the help contract.** Run `verify-docker-images drive cli-help`. Exit 0 requires `gen.py --help` to exit 0, its stdout to contain both `usage:` and `--dry-run`, and its stderr to be empty. Artifacts land in `evidence/cli-help/stdout.txt` and `stderr.txt`.
- **Check the preview contract.** Run `verify-docker-images drive dry-run-sync`. It captures `--dry-run` stdout to `evidence/dry-run-sync/dry-run.yaml` and compares it with `cmp` against the committed `ci.yaml`. Exit 0 requires byte equality; the recorded detail carries the byte count and the `sha256`, e.g. `byte-identical to .github/workflows/ci.yaml (73828 bytes, sha256 93134c388541c0239f3ea0ed5f76179dbf53d23fee9dab066a20dc3c5638c55a)`.
- **Check the repo is in sync.** Run `verify-docker-images doctor`. The `workflow_in_sync` line reports `byte-identical (73828 bytes)`; on drift it reports both sizes and tells you to run `gen.py` and commit.
- **Prove the check fails on drift.** Add `verifyprobe/v9/Dockerfile` without running the generator, then re-run `doctor`. `workflow_in_sync` fails with `dry=78609B committed=73828B`. Run `uv run python gen.py` and it goes green again. Remove the probe directory and regenerate.
- **Prove the check would have caught a byte-level regression.** Revert `sys.stdout.write(workflows)` to `print(workflows)` in `gen.py` and run `drive dry-run-sync`. It fails, and `evidence/dry-run-sync/diff.txt` shows the evidence: a single added blank line at the end of the file (`@@ -1877,3 +1877,4 @@` with a lone `+`). `doctor` reports `dry=73829B committed=73828B`. Restore the fix and both go green.
- **Proof.** `evidence/dry-run-sync/dry-run.yaml` is the captured preview; `diff.txt` exists only on failure. The `cli_help` and `workflow_in_sync` entries in `doctor --json` carry the same assertions in machine-readable form.

## Gotchas

- **`print()` adds a newline; `f.write()` does not.** This repo shipped exactly that bug: the preview had one extra trailing newline, so `--dry-run` was never byte-equal to the committed file and every run showed one phantom blank line. The fix is `sys.stdout.write(workflows)`. If a future change reintroduces the difference, fix `gen.py` — **never** add a trailing-newline fudge to a caller to make the diff disappear. A fudge teaches the next agent to ignore diff output, which is exactly how the original bug survived.
- **A blank line at the end of `diff.txt` is the whole story, not noise.** Do not dismiss it as cosmetic; it is the difference between "in sync" and "not".
- **`--dry-run` covers the workflow only.** It exits before the README is touched, so a green `dry-run-sync` says nothing about the README. Use `drive readme-regen` for that surface.
- **`--dry-run` still runs the full scan.** It is a preview, not a cached artifact; a slow tree makes it slow too.
- **If the default uv cache is not writable,** every helper invocation falls back to `scratch/uv-cache` automatically. Force a location with `VERIFY_UV_CACHE_DIR`. The same fallback exists for a hand-run `uv run python gen.py`, where you would pass `UV_CACHE_DIR=$PWD/.uv-cache` yourself.
- **Run the helper from the repo root.** It resolves the root from its own path and `cd`s there, so a subdirectory invocation still works, but recorded evidence paths are absolute.
