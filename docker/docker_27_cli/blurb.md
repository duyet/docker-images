General CI and runtime base: Docker 27 CLI, plus python3 and zstd. Child Dockerfiles can `FROM` this tag and skip that install, so rebuilds stay cached on the base.
