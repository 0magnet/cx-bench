#!/usr/bin/env bash
# Builds src/c with clang -O2 into $OUT/c/a/bench, and $OUT/c/b/bench with
# src/layout/pad.c linked first, so the code lands at another address. CC
# picks another compiler.
set -eu
source "$(dirname "$0")/../src/form.sh"
CC=${CC:-clang}
D=$OUT/c
mkdir -p "$D/a" "$D/b"
$CC -O2 -o "$D/a/bench" "$ROOT"/src/c/*.c
$CC -O2 -c -o "$D/pad.o" "$ROOT/src/layout/pad.c"
$CC -O2 -o "$D/b/bench" "$D/pad.o" "$ROOT"/src/c/*.c
