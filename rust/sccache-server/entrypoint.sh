#!/bin/bash

cat <<EOF > server.conf
# A public IP address and port that clients will use to connect to this builder.
public_addr = "$PUBLIC_ADDR"

# The URL used to connect to the scheduler (should use https, given an ideal
# setup of a HTTPS server in front of the scheduler)
scheduler_url = "$SCHEDULER_URL"

# This is where client toolchains will be stored.
cache_dir = "/tmp/toolchains"

[builder]
type = "overlay"
# The directory under which a sandboxed filesystem will be created for builds.
build_dir = "/tmp/build"
# The path to the bubblewrap version 0.3.0+ `bwrap` binary.
bwrap_path = "/usr/bin/bwrap"

# https://github.com/mozilla/sccache/blob/main/docs/DistributedQuickstart.md#configure-a-build-server
[scheduler_auth]
type = "token"
token = "$SCHEDULER_AUTH_TOKEN"
EOF

sccache-dist server --config server.conf
