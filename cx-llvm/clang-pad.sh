#!/usr/bin/env bash
# CX_CLANG for the layout b builds: links src/layout/pad.c first, so the
# program code lands at another address. Compiles (-c) pass through.
for a in "$@"; do [[ $a == -c ]] && exec clang "$@"; done
exec clang "$CXBENCH_PAD" "$@"
