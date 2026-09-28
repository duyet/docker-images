# resolve_platform_expression

`resolve_platform_expression` decides the `IMAGE_PLATFORMS` value for one CI job.
Most images build for `linux/amd64,linux/arm64`; two families and three individual
rust tags are amd64-only because their upstream or build features are
arch-limited. Getting this wrong is quiet: the job still runs, it just publishes
an image with a platform the base never supported.

## Sub-features

- `platform-default` an unlisted family resolves to `linux/amd64,linux/arm64` (`DEFAULT_PLATFORMS`).
- `platform-family-override` a family in `SINGLE_ARCH_IMAGES` resolves to `linux/amd64` for every tag. On the committed tree that is `debezium` and `gcloud`.
- `platform-tag-override` a family in `SINGLE_ARCH_TAGS` emits a GitHub expression that narrows to `linux/amd64` only for the listed tags, and stays multi-arch for the rest. On the committed tree that is `rust` with `sccache`, `sccache-scheduler`, `sccache-server`.
- `platform-json-sorted` the tag list inside the expression is `sorted(...)` and `json.dumps`-encoded, so the rendered YAML is stable across runs.
- `platform-committed-match` the expression committed in `ci.yaml` equals what `gen.py` resolves today, for every family. `doctor platforms` is the check.

## How to get to it (user POV)

- Read `IMAGE_PLATFORMS` under a family in `.github/workflows/ci.yaml` to see what a job will build.
- Add a family to `SINGLE_ARCH_IMAGES` in `gen.py` when the whole family is amd64-only, or a tag to `SINGLE_ARCH_TAGS` when only some are.
- Run `uv run python gen.py` and commit, so the workflow picks the change up.
- Run `uv run python gen.py --dry-run` to preview the value before writing.

## Driving it with verify-docker-images

Preconditions:

- `verify-docker-images launch` has run and `.run/instance.json` exists.
- `verify-docker-images doctor` exits 0.
- No Docker daemon is required: this is a string comparison, not a build.

- **Read the distribution.** Run `.cursor/skills/verify-docker-images/bin/verify-docker-images doctor`. The `platforms` line reports `multi-arch=12 single-arch=2 conditional=1 (gen.py == ci.yaml for all 15 families)`. The three numbers are the shape to expect: 15 families total, 2 of them whole-family overrides, 1 emitting a conditional expression.
- **Confirm the values agree with the committed workflow.** The same line asserts, per family, that `resolve_platform_expression(family)` equals the `IMAGE_PLATFORMS` value parsed out of `ci.yaml`. A disagreement is reported by name, for example `rust: gen.py='…' ci.yaml='…'`, and the run fails.
- **Read one family by hand.** Run `grep -A2 'IMAGE_TAG:' .github/workflows/ci.yaml | grep IMAGE_PLATFORMS`, or read the `env:` block of the `debezium` job. It must be `linux/amd64`. The `rust` job must be the conditional expression containing `contains(fromJSON('["sccache", "sccache-scheduler", "sccache-server"]'), matrix.tags)`. Those two are the override sets; the other 12 are the default.
- **Prove the tags inside the expression are the real tags.** Confirm each of `sccache`, `sccache-scheduler`, `sccache-server` exists as `rust/<tag>/Dockerfile` on disk. A tag in `SINGLE_ARCH_TAGS` that no longer exists is dead configuration the generator will still render.
- **Proof.** The `platforms` line in the doctor output, and the corresponding entry under `checks` in `doctor --json`, which also records the `multi_arch` / `single_arch` / `conditional` split. No `drive` recipe writes this surface — it is read-only by nature.

## Gotchas

- **Both override sets exist and they are not interchangeable.** `SINGLE_ARCH_IMAGES` is a family, `SINGLE_ARCH_TAGS` is a family mapping to a set of tags. Putting a family in the first and then also listing tags for it in the second is contradictory; the family check returns first and the tag set is ignored.
- **The conditional expression is a `matrix.tags` test, not a family test.** It is rendered into YAML, so it must survive Jinja's `{% raw %}` escaping. If you reword the template and the braces stop being escaped, `gen.py` will render it as literal text and the job loses its platforms.
- **The `sorted()` call is load-bearing for a clean diff.** Without it, the tag list order depends on set iteration order and `ci.yaml` churns between runs on the same tree, which makes `doctor workflow_in_sync` fail for no real reason.
- **amd64-only is a real constraint, not a preference.** `gcloud` and `debezium` are arch-limited upstream; `sccache` is not. Adding arm64 to build an arm64 image that cannot compile is a red build, not a feature.
- A platform value can be correct in `gen.py` and still wrong in `ci.yaml` if someone hand-edited the workflow. That is exactly the `platforms` mismatch case, and it is the reason this check cross-references instead of only recomputing.
