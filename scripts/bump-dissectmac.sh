#!/usr/bin/env bash
set -euo pipefail

CASK_FILE="$(git rev-parse --show-toplevel)/Casks/dissectmac.rb"
ARM_URL="https://pub-ce87a2625bef4c2dae47d7d3202def2e.r2.dev/DissectMac.dmg"
INTEL_URL="https://pub-ce87a2625bef4c2dae47d7d3202def2e.r2.dev/DissectMac-x64.dmg"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Fetching headers..."
ARM_LAST_MOD=$(curl -sI "$ARM_URL" | grep -i '^last-modified:' | sed 's/^[Ll]ast-[Mm]odified: //; s/\r$//')
INTEL_LAST_MOD=$(curl -sI "$INTEL_URL" | grep -i '^last-modified:' | sed 's/^[Ll]ast-[Mm]odified: //; s/\r$//')

if [ "$ARM_LAST_MOD" != "$INTEL_LAST_MOD" ]; then
	echo "WARNING: ARM and Intel Last-Modified differ — using ARM for version." >&2
	echo "  ARM:    $ARM_LAST_MOD" >&2
	echo "  Intel:  $INTEL_LAST_MOD" >&2
fi

VERSION=$(date -j -f "%a, %d %b %Y %H:%M:%S %Z" "$ARM_LAST_MOD" "+%Y%m%d" 2>/dev/null ||
	date -d "$ARM_LAST_MOD" "+%Y%m%d" 2>/dev/null)

if [ -z "$VERSION" ]; then
	echo "ERROR: could not derive version from Last-Modified header: $ARM_LAST_MOD" >&2
	exit 1
fi

echo "Version: $VERSION"

echo "Downloading ARM DMG..."
curl -sL "$ARM_URL" -o "$TMPDIR/arm.dmg"
ARM_SHA=$(shasum -a 256 "$TMPDIR/arm.dmg" | awk '{print $1}')
echo "ARM sha256: $ARM_SHA"

echo "Downloading Intel DMG..."
curl -sL "$INTEL_URL" -o "$TMPDIR/intel.dmg"
INTEL_SHA=$(shasum -a 256 "$TMPDIR/intel.dmg" | awk '{print $1}')
echo "Intel sha256: $INTEL_SHA"

# Check if cask already at this version
CURRENT_VERSION=$(grep -m1 'version "' "$CASK_FILE" | sed 's/.*version "//; s/".*//')
if [ "$CURRENT_VERSION" = "$VERSION" ]; then
	echo "Cask already at version $VERSION — no update needed."
	exit 0
fi

echo "Updating $CASK_FILE..."

# Update version
sed -i.bak "s/version \".*\"/version \"$VERSION\"/" "$CASK_FILE"

# Update ARM sha256
sed -i.bak0 "/on_arm do/,/end$/ s/sha256 \".*\"/sha256 \"$ARM_SHA\"/" "$CASK_FILE"

# Update Intel sha256
sed -i.bak1 "/on_intel do/,/end$/ s/sha256 \".*\"/sha256 \"$INTEL_SHA\"/" "$CASK_FILE"

rm -f "$CASK_FILE.bak" "$CASK_FILE.bak0" "$CASK_FILE.bak1"

echo "Done. Updated $CASK_FILE to version $VERSION."
echo "Run 'brew style Casks/dissectmac.rb' and 'brew audit --cask dissectmac --online' to verify."
