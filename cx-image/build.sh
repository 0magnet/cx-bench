#!/usr/bin/env bash
# Builds cx and cx-core-image from skycoin-cx, layouts a and b, see
# src/cx-tools.sh. run.sh builds each sized program into an image.
set -eu
"$(dirname "$0")/../src/cx-tools.sh" a b
