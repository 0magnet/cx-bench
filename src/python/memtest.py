"""Address in address, walking ones and moving inversions over 1,048,576
uint32 values once per round."""

N = 1048576
WALK = 65536
ALL = 0xFFFFFFFF


def make(fnv, offset):
    mem = [0] * N

    def run(size):
        h, total = offset, 0
        for _ in range(size):
            s, bad = 0, 0
            for i in range(N):
                mem[i] = i
            for i in range(N):
                read = mem[i]
                if read != i:
                    bad += 1
                s += read
            for i in range(N):
                mem[i] = i ^ ALL
            for i in range(N):
                read = mem[i]
                if read != i ^ ALL:
                    bad += 1
                s += read
            h = fnv(fnv(h, bad), s)
            total += bad
            for bit in range(32):
                pattern = 1 << bit
                s, bad = 0, 0
                for i in range(WALK):
                    mem[i] = pattern
                for i in range(WALK):
                    read = mem[i]
                    if read != pattern:
                        bad += 1
                    s += read
                h = fnv(fnv(h, bad), s)
                total += bad
            for pattern in (0x00000000, 0xFFFFFFFF, 0x55555555, 0xAAAAAAAA):
                inverse = pattern ^ ALL
                s, bad = 0, 0
                for i in range(N):
                    mem[i] = pattern
                for i in range(N):
                    read = mem[i]
                    if read != pattern:
                        bad += 1
                    s += read
                    mem[i] = inverse
                for i in range(N - 1, -1, -1):
                    read = mem[i]
                    if read != inverse:
                        bad += 1
                    s += read
                    mem[i] = pattern
                for i in range(N):
                    read = mem[i]
                    if read != pattern:
                        bad += 1
                    s += read
                h = fnv(fnv(h, bad), s)
                total += bad
        return h, total == 0
    return run
