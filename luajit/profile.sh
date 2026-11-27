#!/usr/bin/env bash
# Runs one benchmark twice in server mode under the LuaJIT profiler (-jp,
# functions and lines, .jp.txt) and then under perf record. perf shows the
# trace code as anonymous addresses, -jp names the Lua lines.
# Usage: profile.sh <name|number> <size>. Writes results/profiles.
set -eu
source "$(dirname "$0")/../src/form.sh"
profile_setup "$@"
luajit -jp=Fl3,"$PROFILE_BASE.jp.txt" "$ROOT/src/luajit/bench.lua" -server <<<"$PROFILE_INPUT" >/dev/null
echo "wrote $PROFILE_BASE.jp.txt"
profile_perf luajit "$ROOT/src/luajit/bench.lua" -server
