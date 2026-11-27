# c

C, src/c built with clang -O2. LAYOUT=b runs a second build with src/layout/pad.c linked first, which moves the code, for the placement delta. CC=gcc builds with gcc instead (not used in the results).

## Install

Arch Linux:

```
sudo pacman -S --needed clang perf
```

Debian or Ubuntu:

```
sudo apt install clang linux-perf   # Ubuntu: linux-tools-generic in place of linux-perf
```

macOS (Homebrew, not tested):

```
xcode-select --install   # Apple clang, profile.sh needs Linux perf
```

Then `./precheck.sh c` from the repository root lists what is still missing.

## Versions of the first results

clang 23.1.4, perf 7.3.

## Use

```
c/build.sh
c/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
c/run.sh -server               # server mode, see the README
c/profile.sh fib 100           # profile into results/profiles
```

profile.sh runs server mode under `perf record -e cpu-clock:u` and writes the flat report to a .perf.txt beside the data.
