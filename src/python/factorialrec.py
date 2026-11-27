"""n! for n 0 to 20 by recursion once per round."""


def factorial(n):
    if n == 0:
        return 1
    return n * factorial(n - 1)


def make(fnv, offset):
    def run(size):
        h, ok = offset, True
        for _ in range(size):
            f = 0
            for n in range(21):
                f = factorial(n)
                h = fnv(h, f)
            ok = ok and f == 2432902008176640000
        return h, ok
    return run
