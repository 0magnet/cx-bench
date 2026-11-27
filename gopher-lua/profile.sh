#!/usr/bin/env bash
# Runs one benchmark twice in server mode with the runtime/pprof CPU
# profiler of the Go runner (CXBENCH_CPUPROFILE). It names gopher-lua's
# functions, not Lua lines.
# Usage: profile.sh <name|number> <size>. Writes results/profiles.
set -eu
source "$(dirname "$0")/../src/form.sh"
profile_setup "$@"
CXBENCH_CPUPROFILE=$PROFILE_BASE.pprof "$OUT/gopher-lua/gopher-lua" "$ROOT/src/lua51/bench.lua" -server <<<"$PROFILE_INPUT" >/dev/null
go tool pprof -top "$OUT/gopher-lua/gopher-lua" "$PROFILE_BASE.pprof" 2>/dev/null | head -40 >"$PROFILE_BASE.pprof.txt"
echo "wrote $PROFILE_BASE.pprof and .pprof.txt, view with go tool pprof -http=: $OUT/gopher-lua/gopher-lua $PROFILE_BASE.pprof"
