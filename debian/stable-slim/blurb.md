General CI and runtime base: Debian stable slim, plus curl, python3, and zstd. Child Dockerfiles can `FROM` this tag and skip that install, so rebuilds stay cached on the base.
