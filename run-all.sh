#!/usr/bin/env bash
# Builds, verifies, times and reports a set of forms. Usage:
#   run-all.sh [native|wasm|all|form,form...] [results directory]
# The default is native into results/<date>. Timing runs one program at a
# time, so keep the machine otherwise idle; the load average of each run is
# recorded. RUNS and MIN pass -runs and -min to harness measure.
set -eu
cd "$(dirname "$0")"
FORMS=${1:-native}
case $FORMS in
native) names="c go tinygo lua luajit gopher-lua python cx-vm cx-image cx-llvm" ;;
wasm) names="c-wasm go-wasm tinygo-wasm lua-wasm cx-llvm-wasm cx-wasm" ;;
all) names="c go tinygo lua luajit gopher-lua python cx-vm cx-image cx-llvm c-wasm go-wasm tinygo-wasm lua-wasm cx-llvm-wasm cx-wasm" ;;
*) names=${FORMS//,/ } ;;
esac
OUT=${2:-results/$(date +%F)}
./precheck.sh harness go $names
for form in $names; do
	echo "== build $form"
	"$form/build.sh"
done
(cd harness && go build -o ../out/harness .)
out/harness verify -forms "$FORMS"
out/harness measure -forms "$FORMS" -out "$OUT" -runs "${RUNS:-5}" -min "${MIN:-2s}"
out/harness report -in "$OUT"
echo "results in $OUT/results.md"
