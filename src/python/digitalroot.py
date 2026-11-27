"""Digital root and additive persistence of every n from 1 to 99,999 once
per round. Each n folds root + 10 * persistence."""


def digit_sum(n):
    total = 0
    while n > 0:
        total += n % 10
        n //= 10
    return total


def make(fnv, offset):
    def run(size):
        h, ok = offset, True
        for _ in range(size):
            for n in range(1, 100000):
                root, persistence = n, 0
                while root >= 10:
                    root = digit_sum(root)
                    persistence += 1
                h = fnv(h, root + 10 * persistence)
                ok = ok and root == 1 + (n - 1) % 9
        return h, ok
    return run
