#!/usr/bin/env bash
# CPython 3, isolated mode (-I).
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="markers selftime server"
form_cmd() { printf '%s\n' "$(command -v python3)" -I "$ROOT/src/python/bench.py" "$1" "$2"; }
form_cmd_empty() { printf '%s\n' "$(command -v python3)" -I "$ROOT/src/python/bench.py" empty; }
form_cmd_server() { printf '%s\n' "$(command -v python3)" -I "$ROOT/src/python/bench.py" -server; }
form_main "$@"
