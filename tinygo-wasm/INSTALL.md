# tinygo-wasm

TinyGo, src/go built for wasm32-wasip1 and run under node:wasi. VARIANT=turbofan adds --no-liftoff.

## Install

Arch Linux:

```
sudo pacman -S --needed tinygo go nodejs
```

Debian or Ubuntu:

```
# TinyGo .deb from https://github.com/tinygo-org/tinygo/releases
sudo apt install golang-go nodejs
```

macOS (Homebrew, not tested):

```
brew install go node tinygo-org/tools/tinygo
```

Then `./precheck.sh tinygo-wasm` from the repository root lists what is still missing.

## Versions of the first results

TinyGo 0.44.0-dev (LLVM 23.1.3), node 26.12.1.

## Use

```
tinygo-wasm/build.sh
tinygo-wasm/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
tinygo-wasm/run.sh -server               # server mode, see the README
tinygo-wasm/profile.sh fib 100           # profile into results/profiles
```

profile.sh runs server mode under `node --cpu-prof`.
