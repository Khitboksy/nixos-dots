#!/usr/bin/env bash
# Bump github.com/AvengeMedia/dankgo to a rev (default: master), refresh
# vendorHash if the dependency set changed, and run the test suite through
# nix build (buildGoModule's checkPhase runs `go test ./...`).
#
# Why the fakeHash dance: vendorHash is the fixed-output path key for the
# vendored dependency tree. After go.mod changes, nix still reuses the old
# realized vendor tree (same output path) and the build dies with a
# confusing "inconsistent vendoring" error instead of a hash mismatch.
# Resetting to lib.fakeHash first forces the vendor derivation to re-run so
# the real hash can be read from the mismatch error.
#
# Usage:
#   ./update.sh              # bump to master
#   ./update.sh <rev>        # bump to a branch, tag, or commit
#   FLAKE=/path/to/flake ./update.sh
set -euo pipefail
cd "$(dirname "$0")"

REV="${1:-master}"
FLAKE="${FLAKE:-/home/helios/builds}"
ATTR="#nixosConfigurations.helios.pkgs.custom.danklrc"
LOG="$(mktemp)"
trap 'rm -f "$LOG"' EXIT

dankgo_pin() {
  awk '/AvengeMedia\/dankgo/ { for (i = 1; i <= NF; i++) if ($i ~ /^v[0-9]/) print $i }' go.mod
}
set_vendor_hash() {
  sed -i "s|vendorHash = .*;|vendorHash = $1;|" default.nix
}
build() {
  nix build "${FLAKE}${ATTR}" --no-link -L 2>&1 | tee "$LOG"
}

OLD="$(dankgo_pin)"
echo ">> dankgo: ${OLD} -> ${REV}"
nix shell nixpkgs#go -c go get "github.com/AvengeMedia/dankgo@${REV}"
nix shell nixpkgs#go -c go mod tidy
NEW="$(dankgo_pin)"
echo ">> pin now: ${NEW}"

echo ">> building (checkPhase runs go test)..."
if build; then
  echo ">> up to date (${NEW})"
  exit 0
fi

if grep -qE 'hash mismatch|inconsistent vendoring' "$LOG"; then
  echo ">> dependency tree changed; re-deriving vendorHash"
  set_vendor_hash lib.fakeHash
  build || true # expected failure: mismatch error carrying the real hash
  HASH="$(sed -n 's/.*got:.*\(sha256-[A-Za-z0-9+/=]*\).*/\1/p' "$LOG" | head -1)"
  if [ -z "$HASH" ]; then
    echo "!! could not parse the new vendorHash from the build log:" >&2
    cat "$LOG" >&2
    exit 1
  fi
  echo ">> vendorHash -> ${HASH}"
  set_vendor_hash "\"${HASH}\""
  if build; then
    echo ">> bumped: ${OLD} -> ${NEW} (vendorHash refreshed)"
    exit 0
  fi
fi

echo "!! build failed:" >&2
cat "$LOG" >&2
exit 1
