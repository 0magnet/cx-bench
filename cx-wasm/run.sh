#!/usr/bin/env bash
# cx.wasm, cx itself built for GOOS=js, running the .cx source on its vm
# under node. VARIANT=default runs node as it ships, turbofan with
# --no-liftoff. CX has no input on vm, so the size goes into the source.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS=""
FORM_VARIANTS="default turbofan"
start() { printf '%s\n' "$(command -v node)" --no-warnings $(node_flags) "$(go env GOROOT)/lib/wasm/wasm_exec_node.js" "$OUT/cx-tools/wasm/cx.wasm" --executor=vm; }
form_cmd() {
	local file
	file=$(cx_sized "$1" "$2" "$OUT/cx-sized") || return 1
	start
	echo "$file"
}
form_cmd_empty() { start; echo "$ROOT/src/cx/empty.cx"; }
form_main "$@"
