#!/usr/bin/env bash
# Runs one benchmark twice in server mode with the runtime/pprof CPU
# profiler (CXBENCH_CPUPROFILE) and writes the profile and its top list.
# Usage: profile.sh <name|number> <size>. Writes results/profiles.
set -eu
source "$(dirname "$0")/../src/form.sh"
profile_setup "$@"
CXBENCH_CPUPROFILE=$PROFILE_BASE.pprof "$OUT/go/a/bench" -server <<<"$PROFILE_INPUT" >/dev/null
go tool pprof -top "$OUT/go/a/bench" "$PROFILE_BASE.pprof" 2>/dev/null | head -40 >"$PROFILE_BASE.pprof.txt"
echo "wrote $PROFILE_BASE.pprof and .pprof.txt, view with go tool pprof -http=: $OUT/go/a/bench $PROFILE_BASE.pprof"
