# Notes on the 2026-11-27 wasm results

Every wasm form under node 26.12.1 on the machine of the native results,
in two variants: `default`, node as it ships (Liftoff first, TurboFan
later), and `turbofan`, `--no-liftoff`. Three timed runs per benchmark,
not five, to keep the set under three hours. A run is at least 2 s and
100 times the start up but at most 10 s, so the forms with a long start up
(go-wasm and lua-wasm under turbofan, cx-wasm) run under 100 times it; the
Notes of `results.md` list them, and their Load percent shows it.

## Best of each language, time per round over the best C wasm

| benchmark | best CX | best Lua | best Go |
|---|---|---|---|
| count | cx-wasm/turbofan 759 | lua-wasm/turbofan 48.6 | tinygo-wasm/turbofan 1.64 |
| fib | cx-llvm-wasm/turbofan 2.97 | lua-wasm/turbofan 34.8 | tinygo-wasm/turbofan 1.00 |
| array | cx-llvm-wasm/turbofan 1.00 | lua-wasm/turbofan 56.0 | tinygo-wasm/turbofan 1.01 |
| struct | cx-llvm-wasm/turbofan 1.17 | lua-wasm/turbofan 97.9 | tinygo-wasm/turbofan 0.94 |
| memtest | cx-llvm-wasm/turbofan 1.07 | lua-wasm/turbofan 41.8 | tinygo-wasm/turbofan 1.04 |
| primes | cx-llvm-wasm/turbofan 0.99 | lua-wasm/turbofan 9.38 | tinygo-wasm/turbofan 1.01 |
| ackermann | cx-llvm-wasm/turbofan 2.78 | lua-wasm/turbofan 25.7 | tinygo-wasm/turbofan 1.01 |
| digitalroot | cx-llvm-wasm/turbofan 1.06 | lua-wasm/turbofan 38.2 | tinygo-wasm/turbofan 1.02 |
| factorialiter | cx-llvm-wasm/turbofan 0.99 | lua-wasm/turbofan 41.9 | tinygo-wasm/turbofan 0.76 |
| factorialrec | cx-llvm-wasm/turbofan 3.26 | lua-wasm/turbofan 95.5 | tinygo-wasm/turbofan 0.93 |
| structs | cx-llvm-wasm/turbofan 1.02 | lua-wasm/turbofan 45.8 | tinygo-wasm/turbofan 0.96 |
| structserialize | cx-llvm-wasm/turbofan 3.86 | lua-wasm/turbofan 1520 | tinygo-wasm/turbofan 4.70 |

* cx-llvm-wasm under TurboFan is within 7 percent of C wasm on array,
  memtest, primes, digitalroot, factorialiter and structs, and 2.8 to 3.9
  times it on fib, ackermann, factorialrec and structserialize, the same
  pattern as native. Its count is precomputed at build time, as in cx-llvm.
* cx-wasm, cx's own vm in cx.wasm, is 60 (primes) to 9300
  (structserialize) times C wasm, 300 to 800 times on most (fib 130 ms a
  round against 0.34 ms), and it starts in 0.5 s, or
  6 s when TurboFan compiles all of cx.wasm first. Its time per round is an
  estimate from the whole run, so with a 6 s start in a 10 s run the
  turbofan spreads reach 20 to 43 percent.
* go-wasm is 1.4 to 11 times TinyGo wasm under TurboFan (structserialize
  272 ns against 25 ns, count 5.9 ms against 0.67 ms).
* Lua 5.4 in wasm under TurboFan is 1.3 to 2.1 times native Lua 5.4.

## Warm up, and why server mode matters here

Under default node a function runs on Liftoff until TurboFan has compiled
it, so a one-shot run mixes both tiers. Server mode shows it: the third run
of one process is the TurboFan speed, the first is not.

| form | benchmark | one-shot | server 1st | server 3rd | turbofan one-shot |
|---|---|---:|---:|---:|---:|
| c-wasm | memtest | 27.8 ms | 35.5 ms | 18.6 ms | 18.6 ms |
| c-wasm | digitalroot | 3.8 ms | 5.8 ms | 1.9 ms | 1.9 ms |
| tinygo-wasm | struct | 157 ns | 256 ns | 67 ns | 65 ns |
| tinygo-wasm | factorialiter | 285 ns | 506 ns | 105 ns | 105 ns |
| go-wasm | count | 11.9 ms | 17.7 ms | 5.9 ms | 5.9 ms |

Under `turbofan` the first and third server runs agree within the spread.
So for wasm the turbofan variant, or the third server run, is the number
to compare; the best of table picks it.

## Sensitivity

* Spread over three runs: under 4 percent for most pairs, higher where a
  long start up meets a 10 s cap (cx-wasm/turbofan up to 43, go-wasm/turbofan
  digitalroot 22) or where tier up lands at a different time (c-wasm array
  30, lua-wasm array 20).
* There is no placement delta for wasm: node places the code.

## Not measured

* Brave: the browser forms were not run, the harness drives no browser
  yet.
* wasmtime: the build host with wasmtime is off at night.
