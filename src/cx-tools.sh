#!/usr/bin/env bash
# Builds the cx tools the cx forms run into $OUT/cx-tools: a/cx and
# a/cx-core-image from skycoin-cx as is, b/ the same with the layout pads of
# src/layout (the vm loop lands at another address), and cx.wasm, cx for
# GOOS=js. CX_SRC is a skycoin-cx checkout. Without it the script clones
# github.com/skycoin/skycoin-cx at CX_REF (main) into $OUT/cx-src.
# Usage: cx-tools.sh [a] [b] [wasm], all three by default.
set -eu
source "$(dirname "$0")/form.sh"
want=${*:-a b wasm}
T=$OUT/cx-tools
if [[ -z ${CX_SRC:-} ]]; then
	CX_SRC=$OUT/cx-src
	if [[ ! -d $CX_SRC/.git ]]; then
		git clone -q --depth 1 --branch "${CX_REF:-main}" https://github.com/skycoin/skycoin-cx "$CX_SRC"
	fi
fi
rev=$(git -C "$CX_SRC" rev-parse HEAD)
mkdir -p "$T"
echo "$rev" >"$T/rev.txt"
stamp() { [[ -f $T/$1/rev.txt && $(cat "$T/$1/rev.txt") == "$rev" ]]; }
build() {
	local dir=$1 src=$2
	mkdir -p "$T/$dir"
	(cd "$src" && go build -o "$T/$dir/cx" ./t11-cx-command-cx && go build -tags=cxcore -o "$T/$dir/cx-core-image" ./t4-cx-command-image)
	echo "$rev" >"$T/$dir/rev.txt"
}
if [[ " $want " == *" a "* ]] && ! stamp a; then
	build a "$CX_SRC"
fi
if [[ " $want " == *" b "* ]] && ! stamp b; then
	rm -rf "$T/src-b" && mkdir -p "$T/src-b"
	git -C "$CX_SRC" archive HEAD | tar -x -C "$T/src-b"
	cp "$ROOT/src/layout/cx-vm-pad.go.txt" "$T/src-b/t3-cx-runtime-vm/aaa_layoutpad.go"
	for d in t11-cx-command-cx t4-cx-command-image; do
		cp "$ROOT/src/layout/cx-main-pad.go.txt" "$T/src-b/$d/zz_layoutpad.go"
	done
	build b "$T/src-b"
	rm -rf "$T/src-b"
fi
if [[ " $want " == *" wasm "* ]] && ! stamp wasm; then
	mkdir -p "$T/wasm"
	(cd "$CX_SRC" && GOOS=js GOARCH=wasm go build -o "$T/wasm/cx.wasm" ./t11-cx-command-cx)
	echo "$rev" >"$T/wasm/rev.txt"
fi
