"""Fills and reads an object of two 100,000 element lists once per round.
The fill depends on the round number."""

SIZE = 100000


class Arrays:
    __slots__ = ("int32s", "int64s")

    def __init__(self):
        self.int32s = [0] * SIZE
        self.int64s = [0] * SIZE


def make(fnv, offset):
    arrays = Arrays()

    def run(size):
        h, ok = offset, True
        for round_number in range(size):
            int32s, int64s = arrays.int32s, arrays.int64s
            for c in range(SIZE):
                int32s[c] = c + round_number
                int64s[c] = c * 3
            total = 0
            for c in range(SIZE):
                total = total + int32s[c] + int64s[c]
            h = fnv(h, total)
            ok = ok and total == 19999800000 + 100000 * round_number
        return h, ok
    return run
