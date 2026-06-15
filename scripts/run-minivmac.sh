#!/bin/bash
# (Re)launch Mini vMac with the project's built .dsk. Expects the
# project to already be built — `make minivmac` runs the build first,
# so invoking via the Makefile is the supported flow. Calling this
# script directly works too if build/ is already populated.
#
# Kills any running Mini vMac before mounting because the emulator
# holds the disk image mmap'd; rewriting it underneath silently
# corrupts the .dsk (missing resource fork).
#
# Usage: ./scripts/run-minivmac.sh [app-name]
#   app-name defaults to the newest .dsk in build/

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
MINIVMAC_APP="$PROJECT_ROOT/deps/minivmac/minivmac-macOS-SEFDHD.app"

if [ -n "${1:-}" ]; then
    DSK="$BUILD_DIR/$1.dsk"
else
    DSK="$(ls -t "$BUILD_DIR"/*.dsk 2>/dev/null | head -1 || true)"
fi

if [ -z "$DSK" ] || [ ! -f "$DSK" ]; then
    echo "No .dsk found in $BUILD_DIR — run \`make build\` first." >&2
    exit 1
fi

pkill -f "$MINIVMAC_APP" 2>/dev/null && sleep 1 || true
open -a "$MINIVMAC_APP" "$DSK"
echo "Launched Mini vMac with $(basename "$DSK")"
