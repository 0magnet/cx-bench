#!/usr/bin/env bash
# Lists every tool each form needs, the version found and what is missing.
# Usage: precheck.sh [form...]. With forms named, it exits 1 when one of
# them misses a tool. With none it lists every form and exits 0.
set -u
cd "$(dirname "$0")" || exit 2

declare -A NEEDS=(
	[harness]="go"
	[c]="clang"
	[c-wasm]="clang llvm-ar tinygo node"
	[go]="go"
	[go-wasm]="go node"
	[tinygo]="tinygo go"
	[tinygo-wasm]="tinygo go node"
	[lua]="lua5.4 lua5.5"
	[luajit]="luajit"
	[lua-wasm]="clang llvm-ar tinygo node curl sha256sum"
	[gopher-lua]="go"
	[python]="python3"
	[cx-vm]="go git"
	[cx-image]="go git"
	[cx-llvm]="go git clang"
	[cx-llvm-wasm]="go git tinygo node"
	[cx-wasm]="go git node"
	[profile]="perf go"
)
ORDER="harness c go tinygo lua luajit gopher-lua python cx-vm cx-image cx-llvm c-wasm go-wasm tinygo-wasm lua-wasm cx-llvm-wasm cx-wasm profile"

# tool_path finds a tool. lua5.5 may be installed as lua.
tool_path() {
	if [[ $1 == clang && -n ${CC:-} ]]; then
		command -v "$CC"
		return
	fi
	command -v "$1" && return
	if [[ $1 == lua5.5 ]] && command -v lua >/dev/null && lua -v 2>&1 | grep -q '^Lua 5\.5'; then
		command -v lua
		return
	fi
	return 1
}

tool_version() {
	case $1 in
	go) go version ;;
	tinygo) tinygo version ;;
	lua5.4 | lua5.5 | luajit) "$2" -v 2>&1 ;;
	llvm-ar) "$2" --version 2>&1 | grep -m1 -i version ;;
	*) "$2" --version 2>&1 ;;
	esac | head -1
}

requested=${*:-}
status=0
printf '%-13s %-10s %-8s %s\n' form tool status version
for form in $ORDER; do
	[[ -n $requested && " $requested " != *" $form "* ]] && continue
	missing=0
	for tool in ${NEEDS[$form]}; do
		if path=$(tool_path "$tool"); then
			printf '%-13s %-10s %-8s %s\n' "$form" "$tool" ok "$(tool_version "$tool" "$path")"
		else
			printf '%-13s %-10s %-8s %s\n' "$form" "$tool" MISSING "see $form/INSTALL.md"
			missing=1
		fi
	done
	if [[ $form == profile ]] && command -v perf >/dev/null; then
		printf '%-13s %-10s %-8s %s\n' profile paranoid info "kernel.perf_event_paranoid=$(cat /proc/sys/kernel/perf_event_paranoid 2>/dev/null), 2 allows user space flat profiles"
	fi
	if [[ -n $requested && $missing == 1 ]]; then
		status=1
	fi
done
for form in $requested; do
	[[ -n ${NEEDS[$form]:-} ]] || { echo "precheck: unknown form $form" >&2; status=1; }
done
exit $status
