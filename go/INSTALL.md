# go

Go, src/go built with the gc compiler. LAYOUT=b compiles src/layout/aaa_pad.go.txt first, which moves the code.

## Install

Arch Linux:

```
sudo pacman -S --needed go perf
```

Debian or Ubuntu:

```
sudo apt install golang-go   # needs Go 1.24 or later, else the tarball from https://go.dev/dl
```

macOS (Homebrew, not tested):

```
brew install go
```

Then `./precheck.sh go` from the repository root lists what is still missing.

## Versions of the first results

go 1.27.3.

## Use

```
go/build.sh
go/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
go/run.sh -server               # server mode, see the README
go/profile.sh fib 100           # profile into results/profiles
```

profile.sh sets CXBENCH_CPUPROFILE, so the program writes a runtime/pprof CPU profile of server mode. View it with `go tool pprof -http=: out/go/a/bench <file>.pprof`.
