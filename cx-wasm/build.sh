#!/usr/bin/env bash
# Builds cx for GOOS=js GOARCH=wasm into $OUT/cx-tools/wasm/cx.wasm, see
# src/cx-tools.sh.
set -eu
"$(dirname "$0")/../src/cx-tools.sh" wasm
