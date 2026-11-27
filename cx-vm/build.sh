#!/usr/bin/env bash
# Builds cx from skycoin-cx, layouts a and b, see src/cx-tools.sh.
set -eu
"$(dirname "$0")/../src/cx-tools.sh" a b
