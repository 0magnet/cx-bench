# tinygo

TinyGo, src/go built with `tinygo build -opt=2 -no-debug`. LAYOUT=b compiles src/layout/aaa_pad.go.txt first.

## Install

Arch Linux:

```
sudo pacman -S --needed tinygo go perf
```

Debian or Ubuntu:

```
# the .deb of https://github.com/tinygo-org/tinygo/releases, and Go
sudo apt install golang-go linux-perf
```

macOS (Homebrew, not tested):

```
brew install go tinygo-org/tools/tinygo
```

Then `./precheck.sh tinygo` from the repository root lists what is still missing.

## Versions of the first results

TinyGo 0.44.0-dev (LLVM 23.1.3), a development build. Any TinyGo release that supports Go 1.24 should do.

## Use

```
tinygo/build.sh
tinygo/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
tinygo/run.sh -server               # server mode, see the README
tinygo/profile.sh fib 100           # profile into results/profiles
```

TinyGo has no runtime/pprof CPU profiler, so profile.sh uses `perf record -e cpu-clock:u`.
