# gopher-lua

gopher-lua v1.1.2, a Lua 5.1 interpreter written in Go, running src/lua51 through gopher-lua/runner. Lua 5.1 numbers are doubles with no bit operators, so the hash is kept in eight 8 bit limbs and costs more than in the other forms; primes, factorialiter and factorialrec need 64 bit integers and have no Lua 5.1 version. Times the program prints come from os.clock.

## Install

Arch Linux:

```
sudo pacman -S --needed go
```

Debian or Ubuntu:

```
sudo apt install golang-go
```

macOS (Homebrew, not tested):

```
brew install go
```

Then `./precheck.sh gopher-lua` from the repository root lists what is still missing.

## Versions of the first results

gopher-lua v1.1.2 built with go 1.27.3.

## Use

```
gopher-lua/build.sh
gopher-lua/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
gopher-lua/run.sh -server               # server mode, see the README
gopher-lua/profile.sh fib 100           # profile into results/profiles
```

profile.sh writes a runtime/pprof CPU profile of the runner (CXBENCH_CPUPROFILE). It names gopher-lua functions, not Lua lines.
