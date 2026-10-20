#!/usr/bin/env bash
# Self-test for the published-vs-master gate. Proves the gate can fail, which is
# the only property that makes it a gate.
#
#   ./tools/test_verify_published.sh          # offline: no registry calls
#   ./tools/test_verify_published.sh --live   # also hits ghcr.io
#
# The offline cases are the important ones: deterministic, and runnable in CI
# where a registry round-trip per case would be slow and flaky. They import the
# tool as a module and substitute its registry probe and its git probes, so no
# network and no real commit graph are touched.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

TOOL=tools/verify_published.py
LIVE=${1:-}
pass=0; fail=0
# A per-run directory, not a fixed path: two checkouts running this script at
# once would otherwise share one probe module, and whichever imported second
# would silently run the other's stubs.
PROBE_DIR=$(mktemp -d)
PROBE=$PROBE_DIR/vp_probe.py
export VP_PROBE_DIR=$PROBE_DIR

ok()  { pass=$((pass+1)); printf '  ok    %s\n' "$1"; }
bad() { fail=$((fail+1)); printf '  FAIL  %s\n' "$1"; }

cat > "$PROBE" <<'PY'
"""Import verify_published.py as a module and stub out the network and git."""
import contextlib
import importlib.util
import io
import sys


def load(path, probe_factory=None):
    """Import the tool, stub the registry token, and optionally install a probe.

    `probe_factory` is called with the module and must RETURN the replacement
    inspect_tag, so the module is in scope for building TagState instances.
    """
    spec = importlib.util.spec_from_file_location("vp", path)
    vp = importlib.util.module_from_spec(spec)
    sys.modules["vp"] = vp  # @dataclass needs the module registered
    spec.loader.exec_module(vp)
    vp.anonymous_token = lambda repo: "t"
    if probe_factory is not None:
        vp.inspect_tag = probe_factory(vp)
    return vp


def stub_git(vp, ancestors, known):
    """Replace the two git probes with fixed answers.

    `ancestors` is a set of (older, newer) pairs that ARE ancestry relations.
    `known` is the set of shas the clone is pretended to contain.
    """
    vp.is_ancestor = lambda older, newer: (older, newer) in ancestors
    vp.known_revision = lambda sha: sha in known


def run_main(vp, argv):
    """Call main() in-process so the module's patched globals stay in effect.

    Re-executing the file through runpy would build a fresh module and discard
    every patch, quietly turning these tests back into live network calls.
    """
    saved = sys.argv
    sys.argv = argv
    out, err = io.StringIO(), io.StringIO()
    try:
        with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            try:
                rc = vp.main()
            except SystemExit as e:
                rc = e.code
    finally:
        sys.argv = saved
    return rc, out.getvalue(), err.getvalue()
PY

echo "tag extraction: only two-level Dockerfiles become tags"
python3 - "$TOOL" <<'PY' && ok "three-level paths, blurb.md and docs are excluded" || bad "tag extraction"
import sys
import os; sys.path.insert(0, os.environ["VP_PROBE_DIR"])
from vp_probe import load
vp = load(sys.argv[1])
tree = ["alpine/one/Dockerfile", "minio/minio_latest/Dockerfile",
        "node/node_22/variant/Dockerfile", "rust/athena/blurb.md", "docs/README.md"]
assert vp.list_tags_from_tree(tree) == ["minio_latest", "one"], vp.list_tags_from_tree(tree)
PY

echo "revision label extraction"
python3 - "$TOOL" <<'PY' && ok "the OCI revision label is read from the config blob" || bad "revision label"
import sys
import os; sys.path.insert(0, os.environ["VP_PROBE_DIR"])
from vp_probe import load

REV = "a" * 40
INDEX = {"manifests": [
    {"digest": "sha256:a", "platform": {"os": "linux", "architecture": "amd64"}},
    {"digest": "sha256:b", "platform": {"os": "linux", "architecture": "arm64", "variant": "v8"}},
    {"digest": "sha256:c", "platform": {"os": "unknown", "architecture": "unknown"}},
]}
CHILD = {"config": {"digest": "sha256:cfg"}}
CONFIG = {"created": "2026-09-28T00:00:00Z",
          "config": {"Labels": {"org.opencontainers.image.revision": REV}}}

def get_json(repo, token, path, accept):
    if path.startswith("blobs/"):
        return CONFIG, None
    if "image.index" in accept or "manifest.list" in accept:
        return INDEX, "sha256:index"
    return CHILD, "sha256:a"

m = load(sys.argv[1])
m.get_json = get_json
st = m.inspect_tag("duyet/docker-images", "t", "x")
assert st.error is None, st.error
assert st.revision == REV, st.revision
# The unknown/unknown child is a BuildKit attestation, not a build.
assert st.platforms == ("linux/amd64", "linux/arm64"), st.platforms
PY

echo "a config blob with no revision label fails closed"
python3 - "$TOOL" <<'PY' && ok "missing label => UNKNOWN, not a pass" || bad "missing label"
import sys
import os; sys.path.insert(0, os.environ["VP_PROBE_DIR"])
from vp_probe import load

INDEX = {"manifests": [{"digest": "sha256:a",
                        "platform": {"os": "linux", "architecture": "amd64"}}]}
CHILD = {"config": {"digest": "sha256:cfg"}}
CONFIG = {"created": "2026-09-28T00:00:00Z", "config": {"Labels": {}}}

def get_json(repo, token, path, accept):
    if path.startswith("blobs/"):
        return CONFIG, None
    if "image.index" in accept or "manifest.list" in accept:
        return INDEX, "sha256:index"
    return CHILD, "sha256:a"

m = load(sys.argv[1])
m.get_json = get_json
st = m.inspect_tag("duyet/docker-images", "t", "x")
assert st.error and "revision" in st.error, st
PY

echo "classification: current, STALE, MISSING and unreadable are told apart"
python3 - "$TOOL" <<'PY' && ok "all four classes classified, exit 1" || bad "classification"
import json, sys, tempfile
import os; sys.path.insert(0, os.environ["VP_PROBE_DIR"])
from vp_probe import load, run_main, stub_git

OLD, MID, NEW = "1" * 40, "2" * 40, "3" * 40
tool = sys.argv[1]

def inspect(m):
    def probe(repo, token, tag):
        return {
            # built from NEW, master last touched it at MID => current
            "current":  m.TagState(tag, NEW,  "2026-09-28T00:00:00Z", ("linux/amd64",)),
            # built from OLD, master last touched it at NEW => stale
            "behind":   m.TagState(tag, OLD,  "2026-09-28T00:00:00Z", ("linux/amd64",)),
            "absent":   m.TagState(tag, None, None, (), error="not found"),
            "broken":   m.TagState(tag, None, None, (), error="HTTP 503"),
        }[tag]
    return probe

m = load(tool, inspect)
stub_git(m, {(OLD, NEW), (MID, NEW), (OLD, MID), (MID, MID)}, {OLD, MID, NEW})

d = tempfile.mkdtemp()
open(f"{d}/tree.txt", "w").write("a/current/Dockerfile\nb/behind/Dockerfile\n")
open(f"{d}/commits.txt", "w").write(f"current {MID}\nbehind {NEW}\n")

rc, out, _ = run_main(m, [tool, "--tree", f"{d}/tree.txt", "--commits", f"{d}/commits.txt",
                          "--tags", "current,behind,absent,broken", "--json"])
doc = json.loads(out)
assert rc == 1, f"expected exit 1, got {rc}"
assert doc["ok"] == ["current"], doc["ok"]
assert [s["tag"] for s in doc["stale"]] == ["behind"], doc["stale"]
assert doc["missing"] == ["absent"], doc["missing"]
assert [u["tag"] for u in doc["unknown"]] == ["broken"], doc["unknown"]
row = doc["stale"][0]
assert row["revision"] == OLD and row["master_touched"] == NEW, row
PY

echo "a tag built from an equal commit is current, not stale"
python3 - "$TOOL" <<'PY' && ok "master_touched == published revision passes" || bad "equal commit"
import json, sys, tempfile
import os; sys.path.insert(0, os.environ["VP_PROBE_DIR"])
from vp_probe import load, run_main, stub_git

SHA = "4" * 40
tool = sys.argv[1]
m = load(tool, lambda mod: (lambda repo, token, tag:
    mod.TagState(tag, SHA, "2026-09-28T00:00:00Z", ("linux/amd64",))))
stub_git(m, {(SHA, SHA)}, {SHA})
d = tempfile.mkdtemp()
open(f"{d}/tree.txt", "w").write("a/x/Dockerfile\n")
open(f"{d}/commits.txt", "w").write(f"x {SHA}\n")
rc, out, _ = run_main(m, [tool, "--tree", f"{d}/tree.txt", "--commits", f"{d}/commits.txt"])
assert rc == 0, f"an equal revision must pass, got {rc}: {out}"
PY

echo "a revision absent from the clone fails closed"
python3 - "$TOOL" <<'PY' && ok "unknown sha => UNKNOWN => exit 1" || bad "unknown revision"
import sys, tempfile
import os; sys.path.insert(0, os.environ["VP_PROBE_DIR"])
from vp_probe import load, run_main, stub_git

SHA = "5" * 40
tool = sys.argv[1]
m = load(tool, lambda mod: (lambda repo, token, tag:
    mod.TagState(tag, SHA, "2026-09-28T00:00:00Z", ("linux/amd64",))))
stub_git(m, set(), set())  # the clone is pretended to be empty
d = tempfile.mkdtemp()
open(f"{d}/tree.txt", "w").write("a/x/Dockerfile\n")
open(f"{d}/commits.txt", "w").write(f"x {SHA}\n")
rc, out, _ = run_main(m, [tool, "--tree", f"{d}/tree.txt", "--commits", f"{d}/commits.txt"])
assert rc == 1, f"an unverifiable revision must exit 1, got {rc}"
assert "UNKNOWN" in out, out
PY

echo "existence without a commit map does not silently pass"
python3 - "$TOOL" <<'PY' && ok "no --commits => every tag UNKNOWN => exit 1" || bad "no commits"
import sys, tempfile
import os; sys.path.insert(0, os.environ["VP_PROBE_DIR"])
from vp_probe import load, run_main, stub_git

SHA = "6" * 40
tool = sys.argv[1]
m = load(tool, lambda mod: (lambda repo, token, tag:
    mod.TagState(tag, SHA, "2026-09-28T00:00:00Z", ("linux/amd64",))))
stub_git(m, {(SHA, SHA)}, {SHA})
d = tempfile.mkdtemp()
open(f"{d}/tree.txt", "w").write("a/x/Dockerfile\n")
rc, out, _ = run_main(m, [tool, "--tree", f"{d}/tree.txt"])
assert rc == 1, f"existence-only must not exit 0, got {rc}"
assert "no commit recorded" in out, out
PY

echo "malformed rows in the commit map are ignored"
python3 - "$TOOL" <<'PY' && ok "non-sha and short rows dropped, usable row kept" || bad "malformed rows"
import sys, tempfile
import os; sys.path.insert(0, os.environ["VP_PROBE_DIR"])
from vp_probe import load, run_main, stub_git

SHA = "7" * 40
tool = sys.argv[1]
m = load(tool, lambda mod: (lambda repo, token, tag:
    mod.TagState(tag, SHA, "2026-09-28T00:00:00Z", ("linux/amd64",))))
stub_git(m, {(SHA, SHA)}, {SHA})
d = tempfile.mkdtemp()
open(f"{d}/tree.txt", "w").write("a/x/Dockerfile\na/y/Dockerfile\n")
open(f"{d}/commits.txt", "w").write(f"x {SHA}\ny notasha\n\nx extra columns here\n")
rc, out, _ = run_main(m, [tool, "--tree", f"{d}/tree.txt", "--commits", f"{d}/commits.txt"])
# y has no usable row => UNKNOWN, so the run fails, and x passes.
assert rc == 1, rc
assert "no commit recorded for this tag" in out, out
PY

echo "refuses to pass on an empty tag set"
: > "$PROBE_DIR/vp_empty.txt"
python3 "$TOOL" --tags "" >/dev/null 2>&1
[ $? -eq 2 ] && ok "empty --tags exits 2, not 0" || bad "empty --tags should exit 2"
python3 "$TOOL" --tree "$PROBE_DIR/vp_empty.txt" >/dev/null 2>&1
[ $? -eq 2 ] && ok "empty tree exits 2, not 0" || bad "empty tree should exit 2"
rm -rf "$PROBE_DIR"

if [ "$LIVE" = "--live" ]; then
  echo "live registry"
  ./tools/collect_commit_shas.sh >/dev/null
  python3 "$TOOL" --tags minio_latest --commits commit-shas.txt >/dev/null 2>&1
  [ $? -eq 0 ] && ok "a real published tag reads clean" || bad "minio_latest should read clean"
  python3 "$TOOL" --tags this_tag_does_not_exist_zzz >/dev/null 2>&1
  [ $? -eq 1 ] && ok "a nonexistent tag fails the gate" || bad "nonexistent tag should exit 1"
  python3 "$TOOL" --tags minio_latest --commits commit-shas.txt --json 2>/dev/null \
    | python3 -c 'import sys,json; d=json.load(sys.stdin); assert d["checked"]==1' \
    && ok "--json emits a parseable document" || bad "--json document"
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
