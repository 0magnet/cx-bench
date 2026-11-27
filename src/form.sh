# shellcheck shell=bash
# form.sh is sourced by every form's build.sh, run.sh and profile.sh. It
# holds the paths, the benchmark names and the run.sh options the harness
# uses, so each form only says how to build and how to start a program.
#
# A form's run.sh sets FORM_CAPS (any of markers selftime server layout),
# optionally FORM_VARIANTS, defines form_cmd <name> <size>, form_cmd_empty
# and, with server in FORM_CAPS, form_cmd_server, then calls form_main.
# Each prints the command to start, one argument per line.

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
OUT=${CXBENCH_OUT:-$ROOT/out}
LAYOUT=${LAYOUT:-a}
BENCH_NAMES=(count fib array struct memtest primes ackermann digitalroot factorialiter factorialrec structs structserialize)

# bench_name turns a benchmark number from 1 to 12 or a name into the name.
bench_name() {
	if [[ $1 =~ ^[0-9]+$ ]]; then
		(($1 >= 1 && $1 <= 12)) || return 1
		echo "${BENCH_NAMES[$1 - 1]}"
		return
	fi
	local name
	for name in "${BENCH_NAMES[@]}"; do
		[[ $name == "$1" ]] && echo "$name" && return
	done
	return 1
}

# cx_sized writes the CX program $1 with its size set to $2 into dir $3 and
# prints the path. The vm subset of CX reads no arguments, see README.md.
cx_sized() {
	local file=$3/$1-$2.cx
	mkdir -p "$3"
	if [[ ! -f $file ]]; then
		sed "s/^var benchSize i32 = 1\$/var benchSize i32 = $2/" "$ROOT/src/cx/$1.cx" >"$file.tmp"
		grep -q "^var benchSize i32 = $2\$" "$file.tmp" || { echo "cx_sized: no benchSize line in $1.cx" >&2; return 1; }
		mv "$file.tmp" "$file"
	fi
	echo "$file"
}

# node_flags prints the node flags of VARIANT: default, or turbofan for
# TurboFan only (no Liftoff baseline compiler).
node_flags() {
	case ${VARIANT:-default} in
	turbofan) echo "--no-liftoff" ;;
	esac
}

form_has() { [[ " $FORM_CAPS " == *" $1 "* ]]; }

form_main() {
	local argv
	case ${1:-} in
	--caps) echo "$FORM_CAPS" ;;
	--variants) echo "${FORM_VARIANTS:-default}" ;;
	--cmd)
		if [[ ${2:-} == empty ]]; then
			form_cmd_empty
		else
			local name
			name=$(bench_name "${2:-}") || { echo "unknown benchmark ${2:-}" >&2; exit 2; }
			form_cmd "$name" "${3:?size}"
		fi
		;;
	--cmd-server)
		form_has server || exit 3
		form_cmd_server
		;;
	-server)
		form_has server || { echo "no server mode in this form" >&2; exit 3; }
		mapfile -t argv < <(form_cmd_server)
		exec "${argv[@]}"
		;;
	empty)
		mapfile -t argv < <(form_cmd_empty)
		exec "${argv[@]}"
		;;
	"" | -h | --help)
		echo "usage: run.sh <name|number> <size> [-time=ms|us] | empty | -server | --caps | --variants | --cmd <name|number|empty> [size] | --cmd-server" >&2
		exit 2
		;;
	*)
		local name
		name=$(bench_name "$1") || { echo "unknown benchmark $1" >&2; exit 2; }
		mapfile -t argv < <(form_cmd "$name" "${2:?size}")
		((${#argv[@]})) || exit 1
		if [[ -n ${3:-} ]] && form_has selftime; then
			argv+=("$3")
		fi
		exec "${argv[@]}"
		;;
	esac
}

# profile_setup reads the arguments of a profile.sh, <name|number> <size>,
# and sets PROFILE_NAME, PROFILE_SIZE, PROFILE_INPUT (server mode lines that
# run the benchmark twice, then 0) and PROFILE_BASE, the path without the
# extension under PROFILE_DIR (results/profiles by default).
profile_setup() {
	PROFILE_NAME=$(bench_name "${1:-}") || { echo "usage: profile.sh <name|number> <size>" >&2; exit 2; }
	PROFILE_SIZE=${2:?usage: profile.sh <name|number> <size>}
	local number dir
	for number in "${!BENCH_NAMES[@]}"; do
		[[ ${BENCH_NAMES[$number]} == "$PROFILE_NAME" ]] && break
	done
	PROFILE_INPUT=$(printf '%d %d us\n%d %d us\n0\n' $((number + 1)) "$PROFILE_SIZE" $((number + 1)) "$PROFILE_SIZE")
	dir=${PROFILE_DIR:-$ROOT/results/profiles}
	mkdir -p "$dir"
	PROFILE_BASE=$dir/$(basename "$(cd "$(dirname "$0")" && pwd)")${VARIANT:+-$VARIANT}-$PROFILE_NAME-$PROFILE_SIZE
}

# profile_perf records the command after it with perf, user space only with
# the cpu-clock software event, which needs no hardware counters and works
# at kernel.perf_event_paranoid=2, and writes the flat report beside the
# data. Call graphs need a lower paranoid setting, then PERF_FLAGS=-g adds
# them. The program's stdin is PROFILE_INPUT.
profile_perf() {
	# shellcheck disable=SC2086
	perf record -q -e cpu-clock:u -F 2000 ${PERF_FLAGS:-} -o "$PROFILE_BASE.perf.data" -- "$@" <<<"$PROFILE_INPUT" >/dev/null
	perf report -i "$PROFILE_BASE.perf.data" --stdio --no-children 2>/dev/null | grep -v '^$' | head -80 >"$PROFILE_BASE.perf.txt"
	echo "wrote $PROFILE_BASE.perf.data and .perf.txt, view with perf report -i $PROFILE_BASE.perf.data"
}
