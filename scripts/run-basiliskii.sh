#!/bin/bash
# Drop the project's built .bin into Basilisk II's shared folder and
# launch the emulator (or rely on its live extfs sync if it's already
# running). Expects the project to already be built — `make basiliskii`
# runs the build first, which is the supported flow.
#
# Usage: ./scripts/run-basiliskii.sh [app-name]
#   app-name defaults to the newest .bin in build/

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
BASILISKII_DIR="$PROJECT_ROOT/deps/basiliskii"
SHARED_DIR="$BASILISKII_DIR/shared"
BASILISKII_BIN="$BASILISKII_DIR/BasiliskII.app/Contents/MacOS/BasiliskII"
PREFS="$BASILISKII_DIR/prefs"

if [ -n "${1:-}" ]; then
    BIN="$BUILD_DIR/$1.bin"
else
    BIN="$(ls -t "$BUILD_DIR"/*.bin 2>/dev/null | grep -v '\.code\.bin$' | head -1 || true)"
fi

if [ -z "$BIN" ] || [ ! -f "$BIN" ]; then
    echo "No .bin found in $BUILD_DIR — run \`make build\` first." >&2
    exit 1
fi

# Regenerate the project-local prefs file each run. BasiliskII needs
# absolute paths for rom/disk/extfs, so we can't ship a static file.
# `--config` keeps these scoped to the project; ~/.basilisk_ii_prefs
# is left untouched.
cat > "$PREFS" <<EOF
rom $BASILISKII_DIR/Quadra.rom
disk $BASILISKII_DIR/System753.dsk
extfs $SHARED_DIR
ramsize 67108864
modelid 14
cpu 4
fpu true
jit true
jitfpu true
frameskip 0
scale_nearest true
EOF

mkdir -p "$SHARED_DIR"
cp "$BIN" "$SHARED_DIR/"
echo "Deployed $(basename "$BIN") to Basilisk II shared folder"

if pgrep -f "$BASILISKII_BIN" >/dev/null 2>&1; then
    echo "Basilisk II already running — shared folder will update live"
else
    # Launch the binary directly so --config is honored. `open -a`
    # discards unknown args to .app bundles, which would make the
    # emulator quit immediately on a missing rom/disk/extfs.
    nohup "$BASILISKII_BIN" --config "$PREFS" >/dev/null 2>&1 &
    disown
    echo "Launched Basilisk II (config: $PREFS)"
fi
