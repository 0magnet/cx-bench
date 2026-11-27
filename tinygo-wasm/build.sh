#!/usr/bin/env bash
# Builds src/go with TinyGo -opt=2 for wasm32-wasip1 into
# $OUT/tinygo-wasm/bench.wasm. Its wasi-libc is what src/wasi/cc.sh uses.
set -eu
source "$(dirname "$0")/../src/form.sh"
mkdir -p "$OUT/tinygo-wasm"
(cd "$ROOT/src/go" && tinygo build -target=wasip1 -opt=2 -no-debug -o "$OUT/tinygo-wasm/bench.wasm" .)
