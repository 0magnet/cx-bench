#!/usr/bin/env bash
# Builds src/go with TinyGo -opt=2 into $OUT/tinygo/a/bench, and b/bench
# with src/layout/aaa_pad.go.txt compiled first.
set -eu
source "$(dirname "$0")/../src/form.sh"
D=$OUT/tinygo
mkdir -p "$D/a" "$D/b"
(cd "$ROOT/src/go" && tinygo build -opt=2 -no-debug -o "$D/a/bench" .)
rm -rf "$D/src-b" && cp -r "$ROOT/src/go" "$D/src-b"
cp "$ROOT/src/layout/aaa_pad.go.txt" "$D/src-b/aaa_pad.go"
(cd "$D/src-b" && tinygo build -opt=2 -no-debug -o "$D/b/bench" .)
rm -rf "$D/src-b"
