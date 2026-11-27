# luajit

LuaJIT 2.1 running src/luajit, the Lua 5.4 programs moved to LuaJIT: doubles below 2^53, the bit library, and uint64_t cdata for the hash, the factorials and Lucas-Lehmer. The clock is clock_gettime(CLOCK_MONOTONIC) through the FFI.

## Install

Arch Linux:

```
sudo pacman -S --needed luajit perf
```

Debian or Ubuntu:

```
sudo apt install luajit linux-perf
```

macOS (Homebrew, not tested):

```
brew install luajit
```

Then `./precheck.sh luajit` from the repository root lists what is still missing.

## Versions of the first results

LuaJIT 2.1.1792588164 (rolling release).

## Use

```
luajit/build.sh
luajit/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
luajit/run.sh -server               # server mode, see the README
luajit/profile.sh fib 100           # profile into results/profiles
```

profile.sh runs server mode under the LuaJIT profiler (`-jp=Fl3`, functions and lines, .jp.txt), then under perf, which shows trace code as anonymous addresses.
