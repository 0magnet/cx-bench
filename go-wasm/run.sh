#!/usr/bin/env bash
# Go GOOS=js GOARCH=wasm under node with $(go env GOROOT)/lib/wasm/wasm_exec_node.js.
# VARIANT=default runs node as it ships, turbofan with --no-liftoff.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="markers selftime server"
FORM_VARIANTS="default turbofan"
start() { printf '%s\n' "$(command -v node)" --no-warnings $(node_flags) "$(go env GOROOT)/lib/wasm/wasm_exec_node.js" "$OUT/go-wasm/bench.wasm"; }
form_cmd() { start; printf '%s\n' "$1" "$2"; }
form_cmd_empty() { start; echo empty; }
form_cmd_server() { start; echo -server; }
form_main "$@"
