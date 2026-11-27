# c-wasm

C, src/c built with clang -O2 for wasm32-wasip1 and run under node:wasi (src/wasi/wasi.mjs). VARIANT=default runs node as it ships, VARIANT=turbofan adds --no-liftoff so every function is compiled by TurboFan. The build links against the wasi-libc that TinyGo builds into its cache, plus the start code, dlmalloc and setjmp shims in src/wasi, so TinyGo must be installed and must have built one wasip1 program first (tinygo-wasm/build.sh does).

## Install

Arch Linux:

```
sudo pacman -S --needed clang llvm tinygo nodejs
```

Debian or Ubuntu:

```
sudo apt install clang llvm nodejs
# TinyGo: the .deb of https://github.com/tinygo-org/tinygo/releases
```

macOS (Homebrew, not tested):

```
brew install llvm node tinygo-org/tools/tinygo
```

Then `./precheck.sh c-wasm` from the repository root lists what is still missing.

## Versions of the first results

clang 23.1.4, TinyGo 0.44.0-dev (LLVM 23.1.3), node 26.12.1.

## Use

```
c-wasm/build.sh
c-wasm/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
c-wasm/run.sh -server               # server mode, see the README
c-wasm/profile.sh fib 100           # profile into results/profiles
```

profile.sh runs server mode under `node --cpu-prof` and writes a .cpuprofile for Chrome DevTools or speedscope.
