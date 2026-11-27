#!/usr/bin/env bash
# C, clang -O2. LAYOUT=b runs the build with the code moved.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="markers selftime server layout"
form_cmd() { printf '%s\n' "$OUT/c/$LAYOUT/bench" "$1" "$2"; }
form_cmd_empty() { printf '%s\n' "$OUT/c/$LAYOUT/bench" empty; }
form_cmd_server() { printf '%s\n' "$OUT/c/$LAYOUT/bench" -server; }
form_main "$@"
