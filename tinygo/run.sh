#!/usr/bin/env bash
# TinyGo -opt=2, native. LAYOUT=b runs the build with the code moved.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="markers selftime server layout"
form_cmd() { printf '%s\n' "$OUT/tinygo/$LAYOUT/bench" "$1" "$2"; }
form_cmd_empty() { printf '%s\n' "$OUT/tinygo/$LAYOUT/bench" empty; }
form_cmd_server() { printf '%s\n' "$OUT/tinygo/$LAYOUT/bench" -server; }
form_main "$@"
