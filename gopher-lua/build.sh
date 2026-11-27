#!/usr/bin/env bash
# Builds gopher-lua/runner, a Go command that runs a Lua 5.1 script with
# github.com/yuin/gopher-lua, into $OUT/gopher-lua/gopher-lua.
set -eu
source "$(dirname "$0")/../src/form.sh"
mkdir -p "$OUT/gopher-lua"
(cd "$ROOT/gopher-lua/runner" && go build -trimpath -o "$OUT/gopher-lua/gopher-lua" .)
