#!/usr/bin/env python3
"""Assert the registry agrees with master.

Nothing in this repo otherwise compares the published images to the tree they
were built from, so `master` can move to a commit whose images were never
published (or were published from an *older* commit) while every check stays
green. This is that comparison.

For every `<family>/<tag>/Dockerfile` in the tree it reads the tag's amd64
config blob from ghcr.io and compares the OCI `org.opencontainers.image.revision`
label — the commit the image was actually built from — against the commit that
last touched that image directory on master. It reports three failure classes:

  MISSING  the tag is not in the registry at all
  STALE    the tag exists, but was built from a commit older than the one that
           last touched its directory on master
  UNKNOWN  the tag could not be read, or the config blob carries no revision
           label; both fail closed rather than pass

The revision label is compared with `git merge-base --is-ancestor`, not by
equality or by timestamp. Equality is wrong in the common case: any commit that
regenerates `.github/workflows/ci.yaml` is in every family's `dorny/paths-filter`
list, so a single push rebuilds all 68 images and stamps them with a commit far
newer than the one that last touched any given directory. And a wall-clock
comparison is unsound in the outage this gate exists to catch: a run that starts
before a commit lands but finishes after it stamps images *newer* than the
commit while building the *older* tree, so `created > commit-time` even though
the content is behind. Ancestry in the commit graph is race-free and costs no
extra registry round trip — the label is in the config blob we already fetch.

The registry is queried unauthenticated. ghcr.io serves anonymous pulls for
public images, and requiring a token here would mean the gate cannot run
outside Actions — which is exactly when it is most useful.

Exit codes:
  0  registry matches master
  1  one or more tags missing, stale, or unknown (details on stdout)
  2  bad input, empty tag set, or registry unreachable
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass

REGISTRY = "ghcr.io"
REPO = "duyet/docker-images"
REVISION_LABEL = "org.opencontainers.image.revision"

INDEX_TYPES = ", ".join([
    "application/vnd.oci.image.index.v1+json",
    "application/vnd.docker.distribution.manifest.list.v2+json",
])
MANIFEST_TYPES = ", ".join([
    "application/vnd.oci.image.manifest.v1+json",
    "application/vnd.docker.distribution.manifest.v2+json",
])
CONFIG_TYPES = "application/vnd.oci.image.config.v1+json, application/vnd.container.image.v1+json"

# A Dockerfile is always exactly two levels deep: scan_images hard-codes it, and a
# three-level Dockerfile is silently invisible to the generator and never reaches
# CI. Anything that does not match this shape is a bug in the tree, not a tag.
DOCKERFILE_RE = re.compile(r"^([^/]+)/([^/]+)/Dockerfile$")


def log(msg: str, file=None) -> None:
    print(msg, file=file or sys.stdout, flush=True)


def short(sha: str, n: int = 7) -> str:
    return sha[:n] if sha else "-"


def anonymous_token(repo: str) -> str:
    """ghcr.io hands out anonymous pull tokens for public repositories."""
    url = f"https://{REGISTRY}/token?scope=repository:{repo}:pull&service={REGISTRY}"
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.load(r)["token"]


def get_json(repo: str, token: str, path: str, accept: str):
    req = urllib.request.Request(
        f"https://{REGISTRY}/v2/{repo}/{path}",
        headers={"Authorization": f"Bearer {token}", "Accept": accept},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r), r.headers.get("Docker-Content-Digest")


@dataclass
class TagState:
    tag: str
    revision: str | None
    created: str | None
    platforms: tuple[str, ...]
    error: str | None = None


def is_ancestor(older: str, newer: str) -> bool:
    """True if `older` is an ancestor of (or equal to) `newer` in this clone."""
    proc = subprocess.run(
        ["git", "merge-base", "--is-ancestor", older, newer],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    return proc.returncode == 0


def known_revision(sha: str) -> bool:
    proc = subprocess.run(
        ["git", "cat-file", "-e", f"{sha}^{{commit}}"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    return proc.returncode == 0


def inspect_tag(repo: str, token: str, tag: str) -> TagState:
    try:
        doc, _ = get_json(repo, token, f"manifests/{tag}", INDEX_TYPES)
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return TagState(tag, None, None, (), error="not found")
        return TagState(tag, None, None, (), error=f"HTTP {e.code}")
    except Exception as e:  # network, TLS, timeouts
        return TagState(tag, None, None, (), error=type(e).__name__)

    manifests = doc.get("manifests", [])
    if not manifests:
        return TagState(tag, None, None, (), error="no manifest index (single-arch tag)")

    platforms = tuple(sorted(
        f"{m['platform']['os']}/{m['platform']['architecture']}"
        for m in manifests
        if m.get("platform", {}).get("architecture")
        # BuildKit appends provenance/SBOM children as `unknown/unknown`. They
        # are attestations, not builds, and counting them would let a tag with
        # no real image pass a platform check.
        and m["platform"].get("os") != "unknown"
    ))
    amd64 = next(
        (m["digest"] for m in manifests
         if m.get("platform", {}).get("architecture") == "amd64"
         and not m.get("platform", {}).get("variant")),
        None,
    )
    if not amd64:
        return TagState(tag, None, None, platforms, error="no linux/amd64 child")

    try:
        manifest, _ = get_json(repo, token, f"manifests/{amd64}", MANIFEST_TYPES)
        config, _ = get_json(repo, token, f"blobs/{manifest['config']['digest']}", CONFIG_TYPES)
    except Exception as e:
        return TagState(tag, None, None, platforms, error=f"config blob: {type(e).__name__}")

    labels = (config.get("config") or {}).get("Labels") or {}
    revision = labels.get(REVISION_LABEL)
    created = config.get("created")
    if not revision:
        return TagState(tag, None, created, platforms,
                        error=f"config blob has no {REVISION_LABEL} label")
    return TagState(tag, revision, created, platforms)


def list_tags_from_tree(files: list[str]) -> list[str]:
    tags = []
    for f in files:
        m = DOCKERFILE_RE.match(f)
        if m:
            tags.append(m.group(2))
    return sorted(set(tags))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--repo", default=REPO, help="repository, e.g. org/name")
    ap.add_argument("--tags", default="",
                    help="comma-separated subset to check (default: every tag in --tree)")
    ap.add_argument("--tree", default="",
                    help="file containing one path per line, e.g. `git ls-tree -r "
                         "--name-only HEAD` output. Required unless --tags is given.")
    ap.add_argument("--commits", default="",
                    help="file of `tag <sha>` lines, from `git log`. Enables the "
                         "STALE check; without it only existence is verified.")
    ap.add_argument("--jobs", type=int, default=8, help="parallel registry requests")
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    args = ap.parse_args()

    if args.tags:
        tags = [t.strip() for t in args.tags.split(",") if t.strip()]
    elif args.tree:
        with open(args.tree) as f:
            tags = list_tags_from_tree([line.strip() for line in f if line.strip()])
    else:
        ap.error("need --tags or --tree")
        return 2
    if not tags:
        log("no tags found — refusing to report success on an empty set")
        return 2

    last_commit: dict[str, str] = {}
    if args.commits:
        with open(args.commits) as f:
            for line in f:
                parts = line.split()
                if len(parts) != 2:
                    continue
                tag, sha = parts
                if re.fullmatch(r"[0-9a-f]{7,40}", sha):
                    last_commit[tag] = sha
        if not last_commit:
            log(f"warning: {args.commits} yielded no usable rows; "
                "the STALE check will be skipped and only existence verified",
                file=sys.stderr)

    if not args.json:
        log(f"checking {len(tags)} tag(s) against {args.repo}")
    try:
        token = anonymous_token(args.repo)
    except Exception as e:
        log(f"fatal: could not obtain a registry token: {type(e).__name__}: {e}")
        return 2

    with ThreadPoolExecutor(max_workers=args.jobs) as pool:
        states = list(pool.map(lambda t: inspect_tag(args.repo, token, t), tags))

    missing, stale, unknown, ok = [], [], [], []
    for s in states:
        if s.error is not None:
            (missing if s.error == "not found" else unknown).append(s)
        elif s.tag not in last_commit:
            # Existence was verified but the revision could not be compared. Do
            # not let an unverified tag pass silently; the gate is only as good
            # as its ability to fail.
            unknown.append(TagState(s.tag, s.revision, s.created, s.platforms,
                                    error="no commit recorded for this tag"))
        elif not known_revision(s.revision):
            unknown.append(TagState(s.tag, s.revision, s.created, s.platforms,
                                    error=f"revision {short(s.revision)} not in this clone"))
        elif not is_ancestor(last_commit[s.tag], s.revision):
            stale.append(s)
        else:
            ok.append(s)

    # Per-tag lines are suppressed in --json mode so stdout stays a single
    # document; the JSON below carries the same information.
    if not args.json:
        for s in missing:
            log(f"MISSING  {s.tag}  not published")
        for s in stale:
            log(f"STALE    {s.tag}  published from {short(s.revision)}, master last "
                f"touched it at {short(last_commit[s.tag])}  [{','.join(s.platforms)}]")
        for s in unknown:
            log(f"UNKNOWN  {s.tag}  {s.error}  [{','.join(s.platforms)}]")

    if args.json:
        # In this mode stdout carries only the JSON document, so it pipes straight
        # into jq. The human summary goes to stderr instead of being interleaved.
        json.dump({
            "repo": args.repo,
            "checked": len(states),
            "missing": [s.tag for s in missing],
            "stale": [{"tag": s.tag,
                   "revision": s.revision,
                   "master_touched": last_commit[s.tag],
                   "platforms": list(s.platforms)} for s in stale],
            "unknown": [{"tag": s.tag, "error": s.error} for s in unknown],
            "ok": [s.tag for s in ok],
        }, sys.stdout, indent=2)
        print()
    else:
        log(f"\n{len(ok)} current, {len(missing)} missing, "
            f"{len(stale)} stale, {len(unknown)} unknown")

    if missing or stale:
        log("registry does not match master — see issue #97", file=sys.stderr)
        return 1
    if unknown:
        log("some tags could not be read; treat as failure until explained",
            file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
