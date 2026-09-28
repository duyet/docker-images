# build_readme

`build_readme` produces the image list, and the write path splices it into the
existing `README.md` between two markers. Everything outside the markers — the
title, the intro, the footer — is hand-written prose that must survive every
regeneration. The safety property that matters is asymmetric: on a broken
README the generator must fail loudly and change nothing, because a half-written
README is worse than a stale one.

## Sub-features

- `readme-markers` content between `<!-- BEGIN IMAGE LIST -->` and `<!-- END IMAGE LIST -->` is fully replaced on every run.
- `readme-footer-preserved` prose after the end marker survives byte-identical.
- `readme-header-preserved` prose before the begin marker survives byte-identical.
- `readme-replaces-stale` an entry for a tag that no longer exists disappears on the next run.
- `readme-idempotent` a second identical run moves zero bytes.
- `readme-rejects-missing-begin` a README with no begin marker exits non-zero and leaves the file untouched.
- `readme-rejects-inverted` markers in the wrong order exit non-zero and leave the file untouched.
- `readme-rejects-only-begin` a begin marker with no end marker exits non-zero and leaves the file untouched.
- `readme-markers-present` the committed README has both markers in order. `doctor readme_markers` is the check.

## How to get to it (user POV)

- Add an image directory, run `uv run python gen.py`, and read the new section in `README.md`.
- Read the pull instructions for a tag from its `###` section.
- Edit prose outside the markers by hand; it is never touched by the generator.
- See what would change before committing, with `uv run python gen.py --dry-run` (workflow only — there is no README dry run).

## Driving it with verify-docker-images

Preconditions:

- `verify-docker-images launch` has run and `.run/instance.json` exists.
- `verify-docker-images doctor` exits 0.
- **The real `README.md` is never a fixture.** Every write-path recipe below runs against a throwaway repo under `scratch/fixtures/`, which holds its own copy of `gen.py`. Because `gen.py` derives its root from `__file__`, the copy's directory is the entire world and the real README is unreachable from inside a fixture.

- **Regenerate a healthy README.** Run `verify-docker-images drive readme-regen`. It builds a fixture with header prose, both markers, a deliberately stale `- [\`stale-family\`](#stale-family)` entry, and a footer, then runs the real `gen.py` against it. Exit 0 requires all of: exit code 0; the footer text after the end marker byte-identical; `Prose above the markers` still present; `stale-family` gone; `## \`verifytool\`` rendered; `### [\`verifytool/v1\`](verifytool/v1/Dockerfile)` rendered; `ci.yaml` written; and a second run leaving `README.md` at the same `sha256`.
- **Reject a missing begin marker.** `drive readme-marker-failures` builds three fixtures, each in its own directory, whose READMEs have respectively no begin marker, the markers inverted, and a begin marker with no end marker. Each case asserts **both** halves of the safety property: `gen.py` exits non-zero, **and** the `sha256` of `README.md` is unchanged from before the run. The recorded detail carries the after-hash, e.g. `missing BEGIN marker: exit 1, README.md byte-unchanged (sha256 5bef8a01a777…)`.
- **Confirm the error is the marker guard.** Each of the three cases also asserts stderr contains `README markers not found or invalid order`, so a non-zero exit for some unrelated reason cannot pass.
- **Confirm the committed README is well formed.** Run `verify-docker-images doctor`. The `readme_markers` line reports `begin=870 end=24937`; a missing or out-of-order marker fails the run before any recipe runs.
- **Proof.** Artifacts under `evidence/readme-marker-failures/`: per variant, `<variant>.stdout.txt`, `<variant>.stderr.txt`, and the `.readme.sha256-before` / `.readme.sha256-after` pair. Under `evidence/readme-regen/`: `README.after.md`, `ci.yaml.after`, `footer-before.txt`, and the two runs' stdout/stderr. A green `drive all` exit 0 is the proof.

## Gotchas

- **`gen.py` is not transactional.** It writes `ci.yaml` **before** it validates the README markers. On a marker failure `ci.yaml` has already been rewritten and only `README.md` is protected. A failed run does not mean an unchanged tree — check `git status`, not just the exit code. This is asserted as an `info` line in every doctor run.
- **A rejected run exits 1 via an uncaught `ValueError`**, so stderr is a Python traceback, not a clean message. Grep for the message inside the traceback rather than expecting a tidy error line.
- **There is no README dry run.** `--dry-run` prints the workflow and exits before touching the README. To preview a README change without writing, copy `gen.py` into a scratch directory and run it there — which is what the fixture recipes do.
- **Marker text must match exactly,** including the leading `<!--` and trailing ` -->`. A marker reformatted into a different style is "missing" to the generator, and the run fails without modifying the README.
- **Do not hand-edit the generated list.** The image list, the `###` sections, and the `docker pull` snippets are all output. If a line looks wrong, fix the source directory or the `blurb.md` and regenerate.
- **Do not remove the footer.** The generator preserves everything after the end marker verbatim, so the end marker is the boundary of its authority. Content after it is safe; content before the begin marker is safe; the span between them is not yours.
