#!/usr/bin/env bash
# Builds src/c with clang -O2 for wasm32-wasip1 into $OUT/c-wasm/bench.wasm,
# through src/wasi/cc.sh (TinyGo's wasi-libc, so TinyGo must be installed).
set -eu
source "$(dirname "$0")/../src/form.sh"
mkdir -p "$OUT/c-wasm"
"$ROOT/src/wasi/cc.sh" -O2 -o "$OUT/c-wasm/bench.wasm" "$ROOT"/src/c/*.c
