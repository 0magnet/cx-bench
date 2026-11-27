#!/usr/bin/env bash
# cx build --target=image, run by cx-core-image on vm. The image is built
# before the run, so Load is reading the image. LAYOUT=b uses the cx built
# with the vm loop moved.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="layout"
image() {
	local source=$1 image=$2
	if [[ ! -f $image ]]; then
		mkdir -p "$(dirname "$image")"
		"$OUT/cx-tools/$LAYOUT/cx" build --target=image "$source" -o "$image" >&2 || return 1
	fi
	echo "$image"
}
form_cmd() {
	local file built
	file=$(cx_sized "$1" "$2" "$OUT/cx-sized") || return 1
	built=$(image "$file" "$OUT/cx-image/$LAYOUT/$(basename "$file" .cx).cximage") || return 1
	printf '%s\n' "$OUT/cx-tools/$LAYOUT/cx-core-image" "$built"
}
form_cmd_empty() {
	local built
	built=$(image "$ROOT/src/cx/empty.cx" "$OUT/cx-image/$LAYOUT/empty.cximage") || return 1
	printf '%s\n' "$OUT/cx-tools/$LAYOUT/cx-core-image" "$built"
}
form_main "$@"
