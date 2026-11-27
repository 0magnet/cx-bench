#!/usr/bin/env bash
# cx build --target=llvm, a native program through clang. LAYOUT=b links
# src/layout/pad.c first. The size goes into the source, so LLVM sees it as
# a constant, see README.md.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="layout"
native() {
	local source=$1 program=$2
	if [[ ! -x $program ]]; then
		mkdir -p "$(dirname "$program")"
		if [[ $LAYOUT == b ]]; then
			CXBENCH_PAD=$OUT/cx-llvm/pad.o CX_CLANG=$ROOT/cx-llvm/clang-pad.sh "$OUT/cx-tools/a/cx" build --target=llvm "$source" -o "$program" >&2 || return 1
		else
			"$OUT/cx-tools/a/cx" build --target=llvm "$source" -o "$program" >&2 || return 1
		fi
		rm -f "$program.ll"
	fi
	echo "$program"
}
form_cmd() {
	local file
	file=$(cx_sized "$1" "$2" "$OUT/cx-sized") || return 1
	native "$file" "$OUT/cx-llvm/$LAYOUT/$1-$2"
}
form_cmd_empty() { native "$ROOT/src/cx/empty.cx" "$OUT/cx-llvm/$LAYOUT/empty"; }
form_main "$@"
