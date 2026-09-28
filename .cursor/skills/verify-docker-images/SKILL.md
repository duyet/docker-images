---
name: verify-docker-images
description: >-
  Prove that this repo's generated files — .github/workflows/ci.yaml and the
  image list inside README.md — are still in sync with the image directory
  tree, by driving gen.py the way a developer does. Use after adding, moving or
  renaming an image directory, when CI skips a build that should have run, when
  asked whether the workflow or README needs regenerating, or before opening a
  PR that touches any <family>/<tag>/ directory, gen.py, or CI config. No
  Docker daemon required.
---

# Verify docker-images

This repo has exactly one load-bearing invariant:

> **Generated files are in sync with the directory tree.**

`.github/workflows/ci.yaml` and the image list in `README.md` are **generated
output**. Add an image directory, forget `gen.py`, and that image's CI build
silently never runs — the path filter, the matrix, and the README entry are all
absent, and nothing in this repo complains. There is no test suite, no server,
and no daemon. `gen.py` is the lever: `--dry-run`, `--help`, no side effects
beyond the two files it owns.

This skill turns "is it in sync?" into one command that produces evidence.
Read `features/README.md`, then the matching feature file, then run the helpers.
Do not improvise a different check and call it verified.

Helpers live in `.cursor/skills/verify-docker-images/bin/verify-docker-images`
and are executable. That file is the source of truth for invocation; this file
is the map.

## Launch

There is no long-lived server. `gen.py` is a **one-shot generator**: launch
means install the uv project once (it needs `jinja2`) and record the run
identity.

```bash
.cursor/skills/verify-docker-images/bin/verify-docker-images launch
```

Writes `.run/instance.json` (`git_head`, `gen_sha256`, resolved uv cache) and
starts no process. Ready when it prints `ok repo_root …` and `ok git_head …`.
`doctor` and `drive` fail closed without it — that is the "is this ours?" check.

Teardown is `cleanup` (below). Launch never needs a network beyond the uv
dependency resolve.

Env:

| Variable | Default | Meaning |
|---|---|---|
| `VERIFY_EVIDENCE` | `<skill>/evidence` | Proof root. Survives cleanup. |
| `VERIFY_UV_CACHE_DIR` | probed | Force a uv cache dir. Unset, the helper probes the default and falls back to `scratch/uv-cache` when it is not writable. |

## Doctor

```bash
.cursor/skills/verify-docker-images/bin/verify-docker-images doctor
.cursor/skills/verify-docker-images/bin/verify-docker-images doctor --json
.cursor/skills/verify-docker-images/bin/verify-docker-images doctor --build            # opt-in
.cursor/skills/verify-docker-images/bin/verify-docker-images doctor --build=node/22
```

Read-only. **Never writes a generated file and never needs a Docker daemon.**
Run it first whenever anything looks off. Exit 0 = the repo is in sync and
drivable; anything else = stop and fix before driving.

The doctor loads `gen.py` as a module and asks the generator itself for the
facts, so it never re-implements `scan_images` and can never drift from it.

| check | meaning |
|---|---|
| `generator` | `gen.py` loads; counts families and tags |
| `image_families` | at least one `<family>/<tag>/Dockerfile` was found |
| `dockerfile_depth` | **every** `Dockerfile` in the tree is exactly `<family>/<tag>/Dockerfile` |
| `blurbs` | inventory of `blurb.md` files and their `<family>/<tag>` pairs |
| `platforms` | `resolve_platform_expression(family)` equals the `IMAGE_PLATFORMS` actually committed in `ci.yaml`, for every family |
| `cli_help` | `gen.py --help` exits 0 and documents `--dry-run` |
| `workflow_in_sync` | **`gen.py --dry-run` is byte-identical to the committed `ci.yaml`** |
| `readme_markers` | both README markers exist and are in order |

`workflow_in_sync` is the answer to the load-bearing question. It compares
**bytes**, so a trailing-newline difference fails it. That is deliberate — see
the `dry-run` gotcha below.

Doctor also prints one `info` line that is not a check: the generator writes
`ci.yaml` **before** it validates the README markers, so a marker failure leaves
`ci.yaml` rewritten and `README.md` untouched. The generator is not
transactional. Do not read a partial failure as "nothing was written".

`--build` is the **opt-in escape hatch** for a genuine `docker buildx build`.
It needs a running daemon, takes minutes, and is never part of the default
path. On a host with no daemon it fails fast and says so.

## Drive

The four proven cases. `drive all` runs them in order and stops at the first
failure. Each is also runnable alone.

```bash
.cursor/skills/verify-docker-images/bin/verify-docker-images drive all
.cursor/skills/verify-docker-images/bin/verify-docker-images drive cli-help --json
.cursor/skills/verify-docker-images/bin/verify-docker-images drive dry-run-sync
.cursor/skills/verify-docker-images/bin/verify-docker-images drive readme-marker-failures
.cursor/skills/verify-docker-images/bin/verify-docker-images drive readme-regen
```

| recipe | asserts |
|---|---|
| `cli-help` | `gen.py --help` exits 0, documents `--dry-run`, writes nothing to stderr |
| `dry-run-sync` | `--dry-run` stdout is byte-identical to the committed `ci.yaml` |
| `readme-marker-failures` | three broken-marker READMEs each exit non-zero **and** leave `README.md` byte-unchanged, each in its own throwaway fixture |
| `readme-regen` | a healthy README regenerates in place: header and footer survive, the stale entry is replaced, the synthetic image is rendered, and a second run moves zero bytes |

Recipes: **`features/cli-contract.md`** (`cli-help`, `dry-run-sync`) and
**`features/build-readme.md`** (`readme-marker-failures`, `readme-regen`).

Both README recipes run against a **fixture**, never the real `README.md`. A
fixture is a throwaway repo under `scratch/fixtures/`: a copy of `gen.py`, one
synthetic image family (`verifytool/v1`), an empty `.github/workflows/`, and one
README variant. `gen.py` derives its root from `__file__`, so the copy's own
directory is the entire universe — the real `README.md` and `ci.yaml` are
unreachable from inside a fixture. This is how "fail loudly, never write a
broken README" is proven without risking the real README.

Exit 0 means every recorded assertion held. Recipes never mutate the repo.

## Evidence

Proof root: **`<skill>/evidence`** (override with `VERIFY_EVIDENCE`). Cleanup
never deletes it. **Gitignored** — live captures stay on disk for agents; never
`git add` them (`evidence/**` except `evidence/README.md`).

```text
evidence/
├── LAST_RUN.txt                 feature, verdict, timestamp, git head
├── all/report.json              the whole run, machine-readable
├── cli-help/{stdout,stderr}.txt
├── dry-run-sync/dry-run.yaml    what --dry-run printed
├── dry-run-sync/diff.txt        only on failure
├── readme-marker-failures/<variant>.{stdout,stderr}.txt
├── readme-marker-failures/<variant>.readme.sha256-{before,after}
└── readme-regen/{README.after.md,ci.yaml.after,footer-before.txt}
```

Standards:

- Exercise the **real `gen.py`**, not a reimplementation. `doctor` importing
  `gen.py` and `drive` executing it are the same lever seen from two sides.
- Capture the **action and the resulting state**: the command, its exit code,
  and the bytes that landed — `sha256` of the README before and after a
  rejected write, `cmp` of a preview against the committed file.
- The three marker-failure cases assert **both** halves: a non-zero exit *and*
  an unmodified `README.md`. Either half alone is not proof of safety.
- A green `drive` exit is the proof. Do **not** commit evidence.

After `cleanup`, confirm `evidence/LAST_RUN.txt` still exists.

## Cleanup

```bash
.cursor/skills/verify-docker-images/bin/verify-docker-images cleanup --dry-run
.cursor/skills/verify-docker-images/bin/verify-docker-images cleanup
```

Removes `.run/` and `scratch/` (the fixtures and any fallback uv cache).
`--dry-run` lists what would go and removes nothing. **Does not** delete
`evidence/`. Run it after every failed drive so a broken attempt does not
strand fixtures.

## Helpers

One executable, invoked from the repo root:

```bash
.cursor/skills/verify-docker-images/bin/verify-docker-images <command> [options]
```

| command | purpose |
|---|---|
| `launch` | install the uv project, record run identity, start nothing |
| `doctor` | read-only pre-flight; `--json`, `--build[=<fam>/<tag>]` |
| `drive <recipe>` | the four proven cases; `--json` |
| `cleanup` | drop `.run/` and `scratch/`; `--dry-run`, `--json` |
| `evidence` | show the last recorded run |
| `help` | full usage |

Exit codes: `0` all assertions held · `1` an assertion failed · `2` usage error.

## Gotchas

- **`--dry-run` must be byte-exact, and this used to be broken.** `gen.py`
  previewed with `print(workflows)` but wrote with `f.write(workflows)`, so
  the preview carried one extra trailing newline and never matched the file a
  real run produced. Fixed in Q1 (`sys.stdout.write`). Never reintroduce a
  newline fudge in a caller to "fix" a diff — that teaches the next agent to
  ignore diffs. `cmp` and `sha256`, not `diff | head`.
- **The tree is two levels deep. `AGENTS.md` says three.** `scan_images`
  hard-codes `<family>/<tag>/Dockerfile`. A `Dockerfile` one level deeper
  (`node/24/probe/Dockerfile`) is **invisible**: no CI job, no README entry, no
  error, and the family/tag counts stay exactly as they were. `doctor
  dockerfile_depth` is the only thing here that sees it. `AGENTS.md` still
  describes a three-level layout; that prose is wrong and is not this skill's
  to fix — trust the tree, and let the doctor catch the mistake.
- **CI builds only what it was told to.** Each job is gated by a
  `dorny/paths-filter` on `$IMAGE_NAME/$IMAGE_TAGS/**`. A stale `ci.yaml`
  means the filter points at a directory that no longer exists, so the job goes
  quiet rather than red.
- **A failed `gen.py` run still rewrote `ci.yaml`.** The workflow is written
  before the README markers are validated. "It errored" does not mean
  "nothing changed" — check `git status`, not just the exit code.
- **The real `README.md` is not a test fixture.** Every README write path
  belongs in a fixture. Hand-editing the generated image list is explicitly out
  of bounds; regenerate instead.
- **No Docker daemon here.** `docker info` fails on
  `/run/user/1000/docker.sock`. The default doctor must never require it. If a
  task genuinely needs a build, `--build` is the escape hatch and it will fail
  here — say so rather than reporting a build as unverified-but-fine.
- **Run from the repo root.** The helper resolves the root from its own path
  (`../../..`) and `cd`s there, so a subdirectory invocation still works, but
  the *evidence* paths printed are absolute.

## Feature map

Index: [`features/README.md`](features/README.md). Five entries, one per
generator concern, named for the `gen.py` symbol it covers:

- [`scan_images`](features/scan-images.md) — directory tree → `{image: [tags]}`
- [`resolve_platform_expression`](features/resolve-platform-expression.md) — platforms per family + both override sets
- [`load_blurbs`](features/load-blurbs.md) — `blurb.md` → README prose
- [`build_readme`](features/build-readme.md) — README between the markers
- [`--dry-run` / CLI contract](features/cli-contract.md) — truthful preview + `--help` exit 0

## Maintenance

When the generator's symbols, override sets, or the two-level rule change, run
`/maintain-verification-skill` so `features/` stays honest. This skill never
edits `ci.yaml` or the README image list by hand — they are generated output.
