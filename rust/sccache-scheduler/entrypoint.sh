#!/bin/bash

cat <<EOF > scheduler.conf
# The socket address the scheduler will listen on. It's strongly recommended
# to listen on localhost and put a HTTPS server in front of it.
public_addr = "$PUBLIC_ADDR"

# https://github.com/mozilla/sccache/blob/main/docs/Distributed.md#server-trust
[client_auth]
type = "token"
token = "$CLIENT_AUTH_TOKEN"

# https://github.com/mozilla/sccache/blob/main/docs/Distributed.md#server-trust
[server_auth]
type = "token"
token = "$SERVER_AUTH_TOKEN"
EOF

sccache-dist scheduler --config scheduler.conf
