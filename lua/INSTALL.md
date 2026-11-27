# lua

PUC Lua running src/lua54. VARIANT=5.4 runs lua5.4, VARIANT=5.5 runs lua5.5 (or lua when that is 5.5). Lua has no monotonic wall clock in its standard library, so the times the program prints itself (-time and server mode) come from os.clock, the CPU time of the process. The phase markers are timed by the harness as for every form.

## Install

Arch Linux:

```
sudo pacman -S --needed lua54 lua perf   # lua is 5.5 on Arch
```

Debian or Ubuntu:

```
sudo apt install lua5.4 linux-perf
# Lua 5.5 is not packaged yet: build it from https://www.lua.org/ftp/ (make linux; install as lua5.5)
```

macOS (Homebrew, not tested):

```
brew install lua   # 5.4 at the time of writing
```

Then `./precheck.sh lua` from the repository root lists what is still missing.

## Versions of the first results

Lua 5.4.9 and Lua 5.5.1.

## Use

```
lua/build.sh
lua/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
lua/run.sh -server               # server mode, see the README
lua/profile.sh fib 100           # profile into results/profiles
```

profile.sh runs server mode under perf on the interpreter. It names interpreter functions, not Lua lines.
