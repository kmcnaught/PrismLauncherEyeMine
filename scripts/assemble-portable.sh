#!/usr/bin/env bash
# Purpose: Assemble EyeMineV2 portable launcher release folder from a Prism Windows build artifact.
#          Layers the pre-configured EyeMineV2 instance (from packaging/) over the launcher
#          binaries and produces a zip ready to share.
# Usage:   ./scripts/assemble-portable.sh <extracted-artifact-dir> [output-dir]
# Example: ./scripts/assemble-portable.sh ~/Downloads/EyeMineV2-Launcher-abc1234
#          ./scripts/assemble-portable.sh ~/Downloads/EyeMineV2-Launcher-abc1234 ~/releases/EyeMineV2-Launcher
# Date created: 2026-05-16

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EYEMINE_ROOT="$(cd "$REPO_ROOT/.." && pwd)"

INSTANCE_SRC="$REPO_ROOT/packaging/eyemine-instance"

ARTIFACT_DIR="${1:?Usage: $0 <extracted-artifact-dir> [output-dir]}"
OUTPUT_DIR="${2:-$EYEMINE_ROOT/EyeMineV2-Launcher}"

INSTANCE_DIR="$OUTPUT_DIR/instances/EyeMineV2"

# Validate inputs
if [[ ! -f "$ARTIFACT_DIR/prismlauncher.exe" ]]; then
    echo "ERROR: prismlauncher.exe not found in $ARTIFACT_DIR"
    echo "Download and extract the artifact from GitHub Actions first."
    exit 1
fi
if [[ ! -d "$INSTANCE_SRC" ]]; then
    echo "ERROR: packaging/eyemine-instance not found at $INSTANCE_SRC"
    exit 1
fi

echo "==> Cleaning output dir: $OUTPUT_DIR"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "==> Copying launcher binaries from artifact"
cp -r "$ARTIFACT_DIR"/. "$OUTPUT_DIR/"
touch "$OUTPUT_DIR/portable.txt"   # ensure portable mode even if artifact omits it

echo "==> Copying EyeMine instance"
mkdir -p "$INSTANCE_DIR/minecraft/mods"   # intentionally empty — populated at launch
cp -r "$INSTANCE_SRC/." "$INSTANCE_DIR/"

echo "==> Zipping"
ZIP_NAME="EyeMineV2-Launcher.zip"
ZIP_PATH="$EYEMINE_ROOT/$ZIP_NAME"
cd "$EYEMINE_ROOT"
rm -f "$ZIP_NAME"
zip -qr "$ZIP_NAME" "EyeMineV2-Launcher/"

echo ""
echo "Done: $ZIP_PATH"
echo "Users: extract anywhere writable (Desktop, Documents), run prismlauncher.exe"
