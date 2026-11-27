#!/usr/bin/env bash
# Runs one benchmark twice in server mode under cProfile and writes the
# profile (.pstats) and its table sorted by own time (.cprofile.txt).
# Usage: profile.sh <name|number> <size>. Writes results/profiles.
set -eu
source "$(dirname "$0")/../src/form.sh"
profile_setup "$@"
python3 -I -m cProfile -o "$PROFILE_BASE.pstats" "$ROOT/src/python/bench.py" -server <<<"$PROFILE_INPUT" >/dev/null
python3 -I -m cProfile -s tottime "$ROOT/src/python/bench.py" -server <<<"$PROFILE_INPUT" | head -40 >"$PROFILE_BASE.cprofile.txt"
echo "wrote $PROFILE_BASE.pstats and .cprofile.txt"
