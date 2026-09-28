# load_blurbs

`load_blurbs` reads an optional `blurb.md` sitting beside a Dockerfile and
returns it as the prose block for that tag in the README. Most tags have none,
and that is the normal case — the blurb is an opt-in extra, not a required
field. Its failure mode is quiet in both directions: a missing blurb produces no
error, and a stale blurb keeps shipping into the README until someone remembers
it exists.

## Sub-features

- `blurb-optional` a tag with no `blurb.md` yields no prose and is not an error.
- `blurb-per-tag` the file is read per `<family>/<tag>`, so one family can have blurbs for some tags and not others.
- `blurb-stripped` surrounding whitespace is stripped, so a trailing newline in the file cannot push a blank line into the README.
- `blurb-in-readme` the text is rendered inside that tag's `###` section, above the `docker pull` snippet.
- `blurb-inventory` the doctor reports which `<family>/<tag>` pairs have blurbs, so a missing or unexpected one is visible without reading the README.

## How to get to it (user POV)

- Drop a `blurb.md` in `<family>/<tag>/` to add descriptive prose to that image's README section.
- Read the rendered prose in `README.md` under the tag's `###` heading.
- Delete a `blurb.md` to remove the prose again.
- List which tags currently have blurbs by reading the `blurbs` line from `verify-docker-images doctor`.

## Driving it with verify-docker-images

Preconditions:

- `verify-docker-images launch` has run and `.run/instance.json` exists.
- `verify-docker-images doctor` exits 0.
- Do not write a real `blurb.md` from a verification recipe. Use a fixture, as `build_readme` does.

- **Inventory the blurbs.** Run `.cursor/skills/verify-docker-images/bin/verify-docker-images doctor`. The `blurbs` line reports `blurb.md files=5 pairs=['debian/stable-slim', 'docker/docker_27_cli', 'node/node_22.14.0_alpine', 'python/python_3.12_slim_bookworm_cairo', 'python/python_3.12_slim_bookworm_runtime']`. The doctor calls `load_blurbs` itself, so this is the generator's answer rather than a `find` result.
- **Confirm the count is sane.** Five blurbs against 64 tags is expected. A sudden jump usually means a `blurb.md` was added to a tag nobody meant to document; a drop to zero means the reads broke, since `load_blurbs` cannot fail on a missing file.
- **Confirm one blurb rendered.** Read the `node_22.14.0_alpine` section in `README.md`. The blurb text appears as the first paragraph of that `###` block, above `Install from the command line`. Compare it against `node/node_22.14.0_alpine/blurb.md`.
- **Confirm a tag without a blurb still renders.** Read any tag with no `blurb.md`. The `###` heading and the `docker pull` snippet are present; only the prose paragraph is absent. The template's `{% if blurbs.get(...) %}` guard is what makes this work.
- **Proof.** The `blurbs` line in the doctor output and the `blurb_pairs` count in `doctor --json`. The rendered result is verified through `drive readme-regen`, which asserts the generated section of a fixture README; for a real blurb, the proof is the README section itself.

## Gotchas

- **Whitespace is stripped, so a deliberate leading blank line is lost.** `.strip()` applies to both ends. Do not use a `blurb.md` to control vertical spacing in the README.
- **A blurb is per tag, not per family.** Adding `blurb.md` to `<family>/` rather than `<family>/<tag>/` is silently ignored, because the path is always `<family>/<tag>/blurb.md`.
- **The blurb is not escaped or sanitised.** It is inserted into the Markdown template as-is. A `###` heading inside a `blurb.md` will produce a heading that outranks the image's own section, so keep blurbs to prose.
- **A stale blurb is indistinguishable from a current one.** Nothing checks that a `blurb.md` still describes the image it sits beside. The doctor inventories the pairs but cannot judge the text; reading the rendered section is the only check.
- **The blurb survives a workflow-only change untouched.** `gen.py` reads blurbs for the README only, so `dry-run-sync` passing tells you nothing about blurb correctness. That is a different feature.
