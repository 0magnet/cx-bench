# python

CPython 3 running src/python in isolated mode (python3 -I). Python is a reference point, not one of the languages the best of table compares.

## Install

Arch Linux:

```
sudo pacman -S --needed python perf
```

Debian or Ubuntu:

```
sudo apt install python3
```

macOS (Homebrew, not tested):

```
brew install python
```

Then `./precheck.sh python` from the repository root lists what is still missing.

## Versions of the first results

Python 3.14.8.

## Use

```
python/build.sh
python/run.sh fib 100 -time=us     # one run of two passes, phase markers on stderr
python/run.sh -server               # server mode, see the README
python/profile.sh fib 100           # profile into results/profiles
```

profile.sh runs server mode under cProfile and writes the .pstats file and the table sorted by own time.
