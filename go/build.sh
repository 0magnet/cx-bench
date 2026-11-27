#!/usr/bin/env bash
# Builds src/go into $OUT/go/a/bench, and $OUT/go/b/bench with
# src/layout/aaa_pad.go.txt compiled first, so the code lands at another
# address.
set -eu
source "$(dirname "$0")/../src/form.sh"
D=$OUT/go
mkdir -p "$D/a" "$D/b"
(cd "$ROOT/src/go" && go build -trimpath -o "$D/a/bench" .)
rm -rf "$D/src-b" && cp -r "$ROOT/src/go" "$D/src-b"
cp "$ROOT/src/layout/aaa_pad.go.txt" "$D/src-b/aaa_pad.go"
(cd "$D/src-b" && go build -trimpath -o "$D/b/bench" .)
rm -rf "$D/src-b"
