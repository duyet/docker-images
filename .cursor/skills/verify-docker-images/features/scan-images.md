# scan_images

`scan_images` turns the image directory tree into the `{family: [tag, …]}` map
that every generated artifact is built from. A tag it does not return gets no CI
job, no workflow matrix entry, and no README section — and nothing in this repo
reports an error, because from the generator's point of view the image simply
does not exist.

## Sub-features

- `scan-two-level` reads only `<family>/<tag>/Dockerfile`; every Dockerfile in the tree is exactly two levels deep.
- `scan-hidden-stray` ignores a Dockerfile nested a level deeper instead of building a job for it. `doctor dockerfile_depth` is the only check that sees one.
- `scan-family-sorted` orders families and tags by name, so the generated YAML and README are stable across runs.
- `scan-empty-drop` removes a top-level directory that has no `<tag>/Dockerfile`, keeping `docs/`, `.github/`, and friends out of the matrix.
- `scan-covered-by-sync` a new family is invisible to the generated files until `gen.py` runs; `doctor workflow_in_sync` is what catches the omission.

## How to get to it (user POV)

- Add `mkdir -p <family>/<tag> && $EDITOR <family>/<tag>/Dockerfile`, then run `uv run python gen.py` and commit the result.
- Read the generated CI matrix in `.github/workflows/ci.yaml` to see the tags that will actually build.
- Read the image list in `README.md` to see what the registry claims exists.
- Use `uv run python gen.py --dry-run` to preview the workflow without writing.

## Driving it with verify-docker-images

Preconditions:

- `verify-docker-images launch` has run and `.run/instance.json` exists.
- `verify-docker-images doctor` exits 0.
- No Docker daemon is required for any of these checks.

- **Inventory the tree.** Run `.cursor/skills/verify-docker-images/bin/verify-docker-images doctor`. The `generator` line reports the family and tag count read straight from `scan_images`; on the committed tree it reads `gen.py loaded, 15 families` and `image_families families=15 tags=64`. The doctor imports `gen.py` as a module rather than re-implementing the scan, so the numbers cannot drift from the generator.
- **Confirm the two-level rule.** The same doctor run reports `dockerfile_depth 64 Dockerfiles, all <family>/<tag>/Dockerfile`. A non-zero count here means at least one Dockerfile is outside the rule; the offending paths are listed and the run fails.
- **Confirm a new family reached the generated files.** Add `verifyprobe/v9/Dockerfile`, then run `doctor`. It fails twice, for two different reasons: `platforms` reports `verifyprobe: absent from ci.yaml (no CI job for this family)`, and `workflow_in_sync` reports `OUT OF SYNC: dry=78609B committed=73828B`. Now run `uv run python gen.py` and re-run `doctor`: both lines go `ok` and the byte count follows. That transition is the proof the family is now wired into CI.
- **Confirm the preview agrees with the file.** Run `verify-docker-images drive dry-run-sync`. It exits 0 only when `--dry-run` stdout is byte-identical to the committed `.github/workflows/ci.yaml`; the recorded detail carries the byte count and the `sha256` of the preview.
- **Proof.** Artifacts under `evidence/dry-run-sync/`: `dry-run.yaml` (what the preview printed) and, on failure, `diff.txt`. The `workflow_in_sync` and `dockerfile_depth` lines are in the doctor output and in `doctor --json`.

## Gotchas

- **`AGENTS.md` describes a three-level layout (`node/<version>/<variant>`). The tree is two levels.** All 64 Dockerfiles are `<family>/<tag>/Dockerfile`, because `scan_images` hard-codes that depth. A three-level Dockerfile is invisible: no job, no README entry, no error, and the family and tag counts do not move — so a count comparison will not catch it either. Only `doctor dockerfile_depth` will. `AGENTS.md` is not corrected by this skill; trust the tree.
- A directory with subdirectories but no `<tag>/Dockerfile` is dropped silently, which is what keeps `docs/` and `.github/` out of the matrix. Do not "fix" that by adding a stray Dockerfile.
- A new family is *absent*, not *broken*. `platforms` is the check that names the missing family by name, so read that line before concluding the generator is confused.
- Compare generated output with `cmp` or `sha256sum`, never `diff | head`. A trailing-newline difference produces a diff that looks like one blank line and is easy to dismiss.
