#!/usr/bin/env bash
# Write the tree and the last commit that touched each image, for verify_published.py.
#
# This lives in a script rather than inline in the Jinja template for two reasons:
# the template is a Python string, so any shell backslash sequence in it is eaten
# before bash ever sees it, and a gate this load-bearing should be testable
# outside Actions.
#
# Outputs, in the repo root:
#   tree.txt         every path in HEAD, for the tag walk
#   commit-shas.txt  "<tag> <full sha>", one row per tag
set -euo pipefail

git ls-tree -r --name-only HEAD > tree.txt

# Dockerfiles are always exactly two levels deep; scan_images hard-codes that and
# a three-level Dockerfile never reaches CI at all. The family is carried through
# so the pathspec below is the real image directory and not a same-named top-level
# entry somewhere else in the repo.
grep -E '^[^/]+/[^/]+/Dockerfile$' tree.txt | cut -d/ -f1,2 | sort -u > dirs.txt

: > commit-shas.txt
while read -r dir; do
    tag=${dir#*/}
    sha=$(git log -1 --format=%H -- "$dir")
    printf '%s %s\n' "$tag" "$sha" >> commit-shas.txt
done < dirs.txt

printf 'collected %s tag(s)\n' "$(wc -l < commit-shas.txt)"
