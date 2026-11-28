"""n! for n 0 to 20 with a loop once per round."""

# zero is the 0 the compiled forms read so no compiler precomputes a round, see
# README.md. It costs the same read here.
zero = 0


def factorial(n):
    result = 1
    for k in range(2, n + 1):
        result *= k
    return result


def make(fnv, offset):
    def run(size):
        h, ok = offset, True
        for _ in range(size):
            f = 0
            for n in range(21 + zero):
                f = factorial(n)
                h = fnv(h, f)
            ok = ok and f == 2432902008176640000
        return h, ok
    return run
