"""Sums 0 to 999,999 once per round."""

# zero is the 0 the compiled forms read so no compiler precomputes a round, see
# README.md. It costs the same read here.
zero = 0


def make(fnv, offset):
    def run(size):
        h, ok = offset, True
        for _ in range(size):
            total = 0
            i = 0
            while i < 1000000:
                total += i + zero
                i += 1
            h = fnv(h, total)
            ok = ok and total == 499999500000
        return h, ok
    return run
