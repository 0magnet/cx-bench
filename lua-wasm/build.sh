#!/usr/bin/env bash
# Builds Lua 5.4.9 from the lua.org source for wasm32-wasip1 into
# $OUT/lua-wasm/lua.wasm, through src/wasi/cc.sh. setjmp and longjmp, which
# Lua uses for errors, become wasm exceptions (-mllvm -wasm-enable-sjlj).
set -eu
source "$(dirname "$0")/../src/form.sh"
VERSION=5.4.9
SHA256=2335b6c582a52654f94612bf10d2f4672805d05329aa6568b1d8cd9e5c6fb8e6
D=$OUT/lua-wasm
tarball=$OUT/dl/lua-$VERSION.tar.gz
mkdir -p "$OUT/dl" "$D"
[[ -f $tarball ]] || curl -fsSL -o "$tarball" "https://www.lua.org/ftp/lua-$VERSION.tar.gz"
echo "$SHA256  $tarball" | sha256sum -c --quiet
rm -rf "$D/build" && mkdir -p "$D/build"
tar -xzf "$tarball" -C "$D/build"
cache=$(tinygo env GOCACHE)
libc=$(ls -td "$cache"/wasi-libc-wasm32-unknown-wasi*/ | head -1)
libc=${libc%/}
cd "$D/build"
for f in lua-$VERSION/src/*.c; do
	b=$(basename "$f" .c)
	[[ $b == luac ]] && continue
	clang --target=wasm32-wasip1 -O2 -DL_tmpnam=32 -mexception-handling -mllvm -wasm-enable-sjlj \
		-isystem "$ROOT/src/wasi/lua-include" -isystem "$ROOT/src/wasi/include" -isystem "$libc/include" -c "$f" -o "$b.o"
done
clang --target=wasm32-wasip1 -O2 -isystem "$libc/include" -c "$ROOT/src/wasi/lua-stubs.c" -o zz-stubs.o
"$ROOT/src/wasi/cc.sh" -O2 -mexception-handling -o "$D/lua.wasm" ./*.o
cd "$D" && rm -rf "$D/build"
