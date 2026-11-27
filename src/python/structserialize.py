"""Encodes a point and 16 int32 into a 72 byte little endian buffer and
decodes them back once per round. The values depend on the round."""


def make(fnv, offset):
    buffer = bytearray(72)

    def encode(at, value):
        buffer[at] = value & 255
        buffer[at + 1] = (value >> 8) & 255
        buffer[at + 2] = (value >> 16) & 255
        buffer[at + 3] = (value >> 24) & 255

    def decode(at):
        v = buffer[at] | buffer[at + 1] << 8 | buffer[at + 2] << 16 | buffer[at + 3] << 24
        return v - 0x100000000 if v >= 0x80000000 else v

    def run(size):
        h, ok = offset, True
        ints, decoded_ints = [0] * 16, [0] * 16
        for round_number in range(size):
            horizontal, vertical = round_number, 2 * round_number
            for k in range(16):
                ints[k] = 16 * round_number + k
            encode(0, horizontal)
            encode(4, vertical)
            for k in range(16):
                encode(8 + 4 * k, ints[k])
            decoded_horizontal = decode(0)
            decoded_vertical = decode(4)
            for k in range(16):
                decoded_ints[k] = decode(8 + 4 * k)
            total = decoded_horizontal + decoded_vertical
            for k in range(16):
                total += decoded_ints[k]
            h = fnv(h, total)
            ok = ok and total == 259 * round_number + 120
        return h, ok
    return run
