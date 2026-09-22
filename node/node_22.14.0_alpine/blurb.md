General CI and runtime base: Node.js 22.14.0 on Alpine, plus python3 and zstd. Child Dockerfiles can `FROM` this tag and skip that install, so rebuilds stay cached on the base.
