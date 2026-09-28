# docker-images verification map

This directory is the maintained source for verifying that the generated files of
this repo — `.github/workflows/ci.yaml` and the image list inside `README.md` —
stay in sync with the image directory tree. Read the index before driving, then
use the matching feature file as the recipe.

There is no running app here. The product surface is a **generator** plus a
**registry of images**, and the thing a user actually depends on is that a tag
they can pull exists in the workflow matrix, in the README, and in a directory
on disk. The primary surface is the CLI (`gen.py`, via
`verify-docker-images`); the Dockerfile tree is the input.

## Baseline preconditions

- Run `.cursor/skills/verify-docker-images/bin/verify-docker-images launch`.
  No server is started; it records the run identity in `.run/instance.json`.
- Run `verify-docker-images doctor` and require exit 0. It is read-only and
  needs no Docker daemon.
- Invoke helpers from the repo root. The helper resolves the root from its own
  path, so a subdirectory invocation still works, but evidence paths are
  absolute.
- Never treat the real `README.md` or `.github/workflows/ci.yaml` as a test
  fixture. Every write-path recipe runs against a throwaway fixture under
  `scratch/fixtures/`, which holds a copy of `gen.py` so the generator's root
  resolves inside the fixture.
- The default path never runs a Docker build. `doctor --build` is the opt-in
  escape hatch and requires a running daemon.

## Ground truth (measured on the committed tree)

| Fact | Value |
|---|---|
| Image families (CI jobs) | 15 — alpine, bun, clickhouse-server, debezium, debian, docker, gcloud, kubeconform, minio, node, postgres, python, redis, rust, upptime |
| Total tags (`<image>/<tag>/Dockerfile`) | 64 |
| Dockerfile depth | all 64 are exactly 2 levels |
| `blurb.md` files | 5 — `node/node_22.14.0_alpine`, `docker/docker_27_cli`, `python/python_3.12_slim_bookworm_cairo`, `python/python_3.12_slim_bookworm_runtime`, `debian/stable-slim` |
| `IMAGE_PLATFORMS` | 12 jobs `linux/amd64,linux/arm64`; 2 jobs `linux/amd64` (debezium, gcloud); 1 conditional (rust) |

These counts move as images are added. Treat them as the shape to expect, not as
values to hardcode — `doctor` recomputes all of them by asking `gen.py` itself.

## Driving conventions

- Treat every command as literal. Keep quoted names and flags unchanged.
- Run checks through `verify-docker-images doctor` and
  `verify-docker-images drive <recipe>`.
- Compare **bytes** (`cmp`, `sha256sum`). A line-level diff that looks empty can
  still differ by a trailing newline, and that is exactly the class of drift
  this repo has already shipped once.
- Write-path proofs use a fixture. Never write to the real `README.md` from a
  recipe.
- A recipe proves one generator concern. Do not report a feature verified
  because a neighbouring feature passed.

## Proof and skip reporting

- Capture the action **and** the resulting bytes: the command, its exit code,
  and the file state that resulted. A non-zero exit alone does not prove a
  rejected write left the file alone.
- For rejected writes, record the `sha256` of the target before and after. The
  file being untouched is the assertion that matters.
- For sync assertions, record both hashes. "They look the same" is not proof.
- Record the feature ID and the recipe used with every artifact.
- Report an unreachable path with the attempted command and the unmet
  precondition. On a host with no Docker daemon, say `doctor --build` could not
  be exercised rather than implying a build was checked.
- Do not report a skipped entry point as verified through a different path.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the
user-visible behavior it protects. It then uses exactly four H2 sections in this
order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with verify-docker-images` starts with `Preconditions:` and uses
   labeled bullets that pair each user action with an exact command and
   observable result.
4. `Gotchas` lists traps that can waste or invalidate a verification run.

Keep implementation details out of the map. Name only user paths, stable
handles, required state, commands, and observable proof.

## Features

- [`scan_images`](./scan-images.md) — the directory tree becomes the set of CI
  families and tags. Covers the two-level rule, the filter that would hide a
  misfiled Dockerfile, and empty-family filtering.
- [`resolve_platform_expression`](./resolve-platform-expression.md) — the
  per-family `IMAGE_PLATFORMS` value, covering both override sets: whole
  families (`SINGLE_ARCH_IMAGES`) and individual tags (`SINGLE_ARCH_TAGS`).
- [`load_blurbs`](./load-blurbs.md) — an optional `blurb.md` beside a Dockerfile
  becomes README prose for that tag, and a missing one is not an error.
- [`build_readme`](./build-readme.md) — README content between the two markers,
  covering in-place regeneration, header/footer preservation, idempotence, and
  the three marker failure modes.
- [`--dry-run` / CLI contract`](./cli-contract.md) — the preview is byte-exact
  with what a write produces, and `--help` exits 0. This is the entry that
  catches "I added an image but forgot to regenerate".
