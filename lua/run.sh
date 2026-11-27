#!/usr/bin/env bash
# PUC Lua, VARIANT=5.4 (lua5.4) or 5.5 (lua5.5, or lua when that is 5.5).
# The variants are the interpreters that are installed.
source "$(dirname "$0")/../src/form.sh"
FORM_CAPS="markers selftime server"
FORM_VARIANTS=$(command -v lua5.4 >/dev/null && echo 5.4; { command -v lua5.5 || lua -v 2>&1 | grep -q "^Lua 5\.5"; } >/dev/null && echo 5.5)
interpreter() {
	case ${VARIANT:-5.4} in
	5.5) command -v lua5.5 || { lua -v 2>&1 | grep -q '^Lua 5\.5' && command -v lua; } ;;
	*) command -v lua5.4 ;;
	esac
}
form_cmd() { printf '%s\n' "$(interpreter)" "$ROOT/src/lua54/bench.lua" "$1" "$2"; }
form_cmd_empty() { printf '%s\n' "$(interpreter)" "$ROOT/src/lua54/bench.lua" empty; }
form_cmd_server() { printf '%s\n' "$(interpreter)" "$ROOT/src/lua54/bench.lua" -server; }
form_main "$@"
