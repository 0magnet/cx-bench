#!/usr/bin/env bash
# Python runs src/python from source, there is nothing to build.
command -v python3 >/dev/null || echo "python: python3 not found, see python/INSTALL.md" >&2
