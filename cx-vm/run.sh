#!/usr/bin/env bash
# cx --executor=vm, the flat vm, running the .cx source. The program is
# parsed and lowered in the Load phase. LAYOUT=b runs cx built with the vm
# loop moved. CX has no input on vm, so the size goes into the source.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="layout"
form_cmd() {
	local file
	file=$(cx_sized "$1" "$2" "$OUT/cx-sized") || return 1
	printf '%s\n' "$OUT/cx-tools/$LAYOUT/cx" --executor=vm "$file"
}
form_cmd_empty() { printf '%s\n' "$OUT/cx-tools/$LAYOUT/cx" --executor=vm "$ROOT/src/cx/empty.cx"; }
form_main "$@"
