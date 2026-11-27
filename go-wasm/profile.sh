#!/usr/bin/env bash
# Runs one benchmark twice in server mode under node --cpu-prof.
# Usage: profile.sh <name|number> <size>. Writes a .cpuprofile, which Chrome
# DevTools (Performance, load profile) or speedscope opens.
set -eu
source "$(dirname "$0")/../src/form.sh"
profile_setup "$@"
mapfile -t argv < <(bash "$(dirname "$0")/run.sh" --cmd-server)
dir=$(mktemp -d)
"${argv[0]}" --cpu-prof --cpu-prof-dir="$dir" "${argv[@]:1}" <<<"$PROFILE_INPUT" >/dev/null
mv "$dir"/*.cpuprofile "$PROFILE_BASE.cpuprofile" && rmdir "$dir"
echo "wrote $PROFILE_BASE.cpuprofile"
