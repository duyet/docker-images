General CI and runtime base: Node.js 22.14.0 on Alpine, plus python3, zstd, and uv 0.6.10. Child Dockerfiles can `FROM` this tag and skip that install, so rebuilds stay cached on the base.
