#!/bin/sh
# Runtime checks for the Cairo base. The image must start Python 3.12,
# load the rendering libraries, provide curl, and ship no compiler.
set -eu

python3 -c 'import sys; raise SystemExit(0 if sys.version.startswith("3.12.") else "python is not 3.12: %s" % sys.version)'

python3 -c '
import ctypes
for name in ("libpango-1.0.so.0", "libcairo.so.2", "libgdk_pixbuf-2.0.so.0"):
    ctypes.CDLL(name)
'

command -v curl >/dev/null

if command -v gcc >/dev/null 2>&1; then
  echo "gcc is installed" >&2
  exit 1
fi

# apt-get install records Install lines. A full upgrade records Upgrade lines.
if [ -f /var/log/apt/history.log ] && grep -q "^Upgrade:" /var/log/apt/history.log; then
  echo "apt upgrade ran in this image" >&2
  exit 1
fi
