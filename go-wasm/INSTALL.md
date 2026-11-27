# go-wasm

Go, src/go built for GOOS=js GOARCH=wasm and run under node with Go's own `$(go env GOROOT)/lib/wasm/wasm_exec_node.js`. VARIANT=turbofan adds --no-liftoff.

## Install

Arch Linux:

```
sudo pacman -S --needed go nodejs
```

Debian or Ubuntu:

```
sudo apt install golang-go nodejs
```

macOS (Homebrew, not tested):

```
brew install go node
```

Then `./precheck.sh go-wasm` from the repository root lists what is still missing.

## Versions of the first results

go 1.27.3, node 26.12.1.

## Use

```
go-wasm/build.sh
go-wasm/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
go-wasm/run.sh -server               # server mode, see the README
go-wasm/profile.sh fib 100           # profile into results/profiles
```

profile.sh runs server mode under `node --cpu-prof`.
