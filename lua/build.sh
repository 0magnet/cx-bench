#!/usr/bin/env bash
# Lua runs src/lua54 from source, there is nothing to build. This checks
# that the interpreters are there.
source "$(dirname "$0")/../src/form.sh"
for lua in lua5.4 lua5.5; do
	command -v "$lua" >/dev/null || echo "lua: $lua not found, see lua/INSTALL.md" >&2
done
