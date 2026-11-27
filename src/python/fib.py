"""Recursive fib(25), 242,785 calls, once per round."""


def fib(n):
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)


def make(fnv, offset):
    def run(size):
        h, ok = offset, True
        for _ in range(size):
            r = fib(25)
            h = fnv(h, r)
            ok = ok and r == 75025
        return h, ok
    return run
