# lua-wasm

PUC Lua 5.4.9 built from the lua.org source for wasm32-wasip1 (setjmp and longjmp as wasm exceptions), running src/lua54 under node:wasi. build.sh downloads the source and checks its sha256. VARIANT=turbofan adds --no-liftoff. The times the program prints come from os.clock, as in the lua form.

## Install

Arch Linux:

```
sudo pacman -S --needed clang llvm tinygo nodejs curl
```

Debian or Ubuntu:

```
sudo apt install clang llvm nodejs curl
# TinyGo .deb from https://github.com/tinygo-org/tinygo/releases
```

macOS (Homebrew, not tested):

```
brew install llvm node tinygo-org/tools/tinygo
```

Then `./precheck.sh lua-wasm` from the repository root lists what is still missing.

## Versions of the first results

Lua 5.4.9, clang 23.1.4, TinyGo 0.44.0-dev (LLVM 23.1.3), node 26.12.1.

## Use

```
lua-wasm/build.sh
lua-wasm/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
lua-wasm/run.sh -server               # server mode, see the README
lua-wasm/profile.sh fib 100           # profile into results/profiles
```

profile.sh runs server mode under `node --cpu-prof`.
