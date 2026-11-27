#!/usr/bin/env bash
# Runs one benchmark twice in server mode under perf record, C symbols kept.
# Usage: profile.sh <name|number> <size>. Writes results/profiles.
set -eu
source "$(dirname "$0")/../src/form.sh"
profile_setup "$@"
mapfile -t argv < <(bash "$(dirname "$0")/run.sh" --cmd-server)
profile_perf "${argv[@]}"
