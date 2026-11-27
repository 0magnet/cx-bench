#!/usr/bin/env bash
# LuaJIT 2.1 with the JIT on.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="markers selftime server"
form_cmd() { printf '%s\n' "$(command -v luajit)" "$ROOT/src/luajit/bench.lua" "$1" "$2"; }
form_cmd_empty() { printf '%s\n' "$(command -v luajit)" "$ROOT/src/luajit/bench.lua" empty; }
form_cmd_server() { printf '%s\n' "$(command -v luajit)" "$ROOT/src/luajit/bench.lua" -server; }
form_main "$@"
