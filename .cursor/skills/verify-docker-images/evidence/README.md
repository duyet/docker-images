# Proof artifacts (local only)

`drive` writes `LAST_RUN.txt`, `all/report.json`, and one directory per recipe
here. `cleanup` must not delete this directory.

These captures are **gitignored** (`evidence/**` except this README). They
change on every run — byte counts, hashes, timestamps — even when the repo did
not. Do **not** `git add` them: a green `drive` exit is the proof, and the
recorded output in the PR body is the record.

| Path | Recipe | What it holds |
|---|---|---|
| `LAST_RUN.txt` | any | feature, verdict, timestamp, git head |
| `all/report.json` | `drive all` | every recorded case, machine-readable |
| `cli-help/` | `drive cli-help` | `--help` stdout and stderr |
| `dry-run-sync/` | `drive dry-run-sync` | the captured preview; `diff.txt` on failure only |
| `readme-marker-failures/` | `drive readme-marker-failures` | per variant: stdout, stderr, and the README `sha256` before and after |
| `readme-regen/` | `drive readme-regen` | the regenerated fixture README, the fixture `ci.yaml`, and the footer comparison |

After `cleanup`, confirm `LAST_RUN.txt` still exists here.
