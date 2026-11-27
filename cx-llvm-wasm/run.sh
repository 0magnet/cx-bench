#!/usr/bin/env bash
# cx build --target=llvm linked by TinyGo for wasm32-wasip1, under
# node:wasi. VARIANT=default runs node as it ships, turbofan with
# --no-liftoff. The size goes into the source, so LLVM sees a constant.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS=""
FORM_VARIANTS="default turbofan"
module() {
	local source=$1 wasm=$2
	if [[ ! -f $wasm ]]; then
		mkdir -p "$(dirname "$wasm")"
		CX_TINYGO_FLAGS="-opt=2 -no-debug" "$OUT/cx-tools/a/cx" build --target=llvm --llvm-linker=tinygo --llvm-tinygo-target=wasip1 "$source" -o "$wasm" >&2 || return 1
		rm -f "$wasm.ll"
	fi
	printf '%s\n' "$(command -v node)" --no-warnings $(node_flags) "$ROOT/src/wasi/wasi.mjs" "$wasm"
}
form_cmd() {
	local file
	file=$(cx_sized "$1" "$2" "$OUT/cx-sized") || return 1
	module "$file" "$OUT/cx-llvm-wasm/$1-$2.wasm"
}
form_cmd_empty() { module "$ROOT/src/cx/empty.cx" "$OUT/cx-llvm-wasm/empty.wasm"; }
form_main "$@"
