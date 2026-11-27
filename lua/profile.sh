#!/usr/bin/env bash
# Runs one benchmark twice in server mode under perf record on the Lua
# interpreter, VARIANT=5.4 or 5.5. perf names interpreter functions, not Lua lines.
# Usage: profile.sh <name|number> <size>. Writes results/profiles.
set -eu
source "$(dirname "$0")/../src/form.sh"
profile_setup "$@"
mapfile -t argv < <(bash "$(dirname "$0")/run.sh" --cmd-server)
profile_perf "${argv[@]}"
