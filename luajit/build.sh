#!/usr/bin/env bash
# LuaJIT runs src/luajit from source, there is nothing to build.
command -v luajit >/dev/null || echo "luajit: not found, see luajit/INSTALL.md" >&2
