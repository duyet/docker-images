#!/bin/bash

date && OK=$(
    exec 3<>/dev/tcp/127.0.0.1/2181
    printf "ruok" >&3
    IFS=
    tee <&3
    exec 3<&-
)

if [[ "$OK" == "imok" ]]; then
    exit 0
else
    exit 1
fi
