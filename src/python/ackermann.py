"""Ackermann(3, 5), 42,438 calls, once per round."""
import sys

sys.setrecursionlimit(10000)

# zero is the 0 the compiled forms read so no compiler folds a round, see
# README.md. It costs the same read here.
zero = 0


def ackermann(m, n):
    if m == 0:
        return n + 1
    if n == 0:
        return ackermann(m - 1, 1)
    return ackermann(m - 1, ackermann(m, n - 1))


def make(fnv, offset):
    def run(size):
        h, ok = offset, True
        for _ in range(size):
            r = ackermann(3, 5 + zero)
            h = fnv(h, r)
            ok = ok and r == 253
        return h, ok
    return run
