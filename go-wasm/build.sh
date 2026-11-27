#!/usr/bin/env bash
# Builds src/go for GOOS=js GOARCH=wasm into $OUT/go-wasm/bench.wasm. It
# runs under node with Go's own lib/wasm/wasm_exec_node.js.
set -eu
source "$(dirname "$0")/../src/form.sh"
mkdir -p "$OUT/go-wasm"
(cd "$ROOT/src/go" && GOOS=js GOARCH=wasm go build -trimpath -o "$OUT/go-wasm/bench.wasm" .)
