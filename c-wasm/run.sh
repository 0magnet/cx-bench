#!/usr/bin/env bash
# C, clang -O2 for wasm32-wasip1, under node:wasi. VARIANT=default runs node as it ships,
# turbofan with --no-liftoff, so every function is compiled by TurboFan.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="markers selftime server"
FORM_VARIANTS="default turbofan"
export CXBENCH_PREOPEN=$ROOT
start() { printf '%s\n' "$(command -v node)" --no-warnings $(node_flags) "$ROOT/src/wasi/wasi.mjs" "$OUT/c-wasm/bench.wasm"; }
form_cmd() { start; printf '%s\n'  "$1" "$2"; }
form_cmd_empty() { start; printf '%s\n'  empty; }
form_cmd_server() { start; printf '%s\n'  -server; }
form_main "$@"
