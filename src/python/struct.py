"""Walks 100 points, objects of two fields, once per round."""

# zero is the 0 the compiled forms read so no compiler precomputes a round, see
# README.md. It costs the same read here.
zero = 0


class Point:
    __slots__ = ("horizontal", "vertical")

    def __init__(self, horizontal, vertical):
        self.horizontal = horizontal
        self.vertical = vertical


def make(fnv, offset):
    def run(size):
        h, ok = offset, True
        points = [Point(i, 2 * i) for i in range(100)]
        for _ in range(size):
            total = 0
            for i in range(100 + zero):
                p = points[i]
                total = total + p.horizontal + p.vertical
            h = fnv(h, total)
            ok = ok and total == 14850
        return h, ok
    return run
