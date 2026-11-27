#!/usr/bin/env bash
# PUC Lua 5.4.9 built for wasm32-wasip1, running src/lua54 under node:wasi. VARIANT=default runs node as it ships,
# turbofan with --no-liftoff, so every function is compiled by TurboFan.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="markers selftime server"
FORM_VARIANTS="default turbofan"
export CXBENCH_PREOPEN=$ROOT
start() { printf '%s\n' "$(command -v node)" --no-warnings $(node_flags) "$ROOT/src/wasi/wasi.mjs" "$OUT/lua-wasm/lua.wasm"; }
form_cmd() { start; printf '%s\n' "$ROOT/src/lua54/bench.lua" "$1" "$2"; }
form_cmd_empty() { start; printf '%s\n' "$ROOT/src/lua54/bench.lua" empty; }
form_cmd_server() { start; printf '%s\n' "$ROOT/src/lua54/bench.lua" -server; }
form_main "$@"
