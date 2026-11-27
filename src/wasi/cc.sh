#!/usr/bin/env bash
# clang for wasm32-wasip1 against the wasi-libc and compiler-rt that TinyGo
# builds into its cache, plus crt.c, dlmalloc and sjlj.c of this directory,
# which that wasi-libc leaves out. Run a TinyGo wasip1 build once first so
# the cache holds them. Extra clang flags pass through.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
OUT=${CXBENCH_OUT:-$here/../../out}
cache=$(tinygo env GOCACHE)
libc=$(ls -td "$cache"/wasi-libc-wasm32-unknown-wasi*/ 2>/dev/null | head -1)
libc=${libc%/}
rt=$(ls -td "$cache"/compiler-rt-wasm32-unknown-wasi*/ 2>/dev/null | head -1)
rt=${rt%/}
if [[ -z $libc || -z $rt ]]; then
	echo "cc.sh: no TinyGo wasi-libc in $cache, run tinygo/build.sh or tinygo-wasm/build.sh first" >&2
	exit 1
fi
lib=$OUT/wasi/libbench.a
if [[ ! -f $lib ]]; then
	mkdir -p "$OUT/wasi"
	clang --target=wasm32-wasip1 -O2 -isystem "$libc/include" -c "$here/crt.c" -o "$OUT/wasi/crt.o"
	clang --target=wasm32-wasip1 -O2 -isystem "$libc/include" -c "$(tinygo env TINYGOROOT)/lib/wasi-libc/dlmalloc/src/dlmalloc.c" -o "$OUT/wasi/dlmalloc.o"
	clang --target=wasm32-wasip1 -O2 -mexception-handling -c "$here/sjlj.c" -o "$OUT/wasi/sjlj.o"
	llvm-ar rcs "$lib" "$OUT/wasi/crt.o" "$OUT/wasi/dlmalloc.o" "$OUT/wasi/sjlj.o"
fi
exec clang --target=wasm32-wasip1 -nostdlib -isystem "$here/include" -isystem "$libc/include" "$@" "$lib" "$libc/lib.a" "$rt/lib.a" "$lib" -Wl,--strip-debug
