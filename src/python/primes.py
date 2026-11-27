"""Sieve below 2,000,000, Miller-Rabin below 300,000 and Lucas-Lehmer 20
times for the odd prime exponents 3 to 61, once per round."""

SIEVE_N = 2000000
EXPONENTS = (3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61)


def pow_mod(base, exponent, modulus):
    result, power = 1, base % modulus
    while exponent > 0:
        if exponent & 1:
            result = result * power % modulus
        power = power * power % modulus
        exponent >>= 1
    return result


def witness(a, d, s, n):
    composite = False
    if a % n != 0:
        x = pow_mod(a, d, n)
        if x != 1 and x != n - 1:
            composite = True
            r = 1
            while r < s and composite:
                x = x * x % n
                if x == n - 1:
                    composite = False
                r += 1
    return composite


def miller_rabin(n):
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    return not witness(2, d, s, n) and not witness(7, d, s, n) and not witness(61, d, s, n)


def mul_mod(x, y, modulus):
    result, addend = 0, x % modulus
    while y > 0:
        if y & 1:
            result += addend
            if result >= modulus:
                result -= modulus
        addend += addend
        if addend >= modulus:
            addend -= modulus
        y >>= 1
    return result


def lucas_lehmer(exponent):
    modulus, s = (1 << exponent) - 1, 4
    for _ in range(exponent - 2):
        s = mul_mod(s, s, modulus)
        s = (s + modulus - 2) % modulus
    return s == 0


def make(fnv, offset):
    sieve = [0] * SIEVE_N

    def run(size):
        h, ok = offset, True
        for _ in range(size):
            for i in range(2, SIEVE_N):
                sieve[i] = 1
            i = 2
            while i * i < SIEVE_N:
                if sieve[i] == 1:
                    for j in range(i * i, SIEVE_N, i):
                        sieve[j] = 0
                i += 1
            count = 0
            for k in range(2, SIEVE_N):
                count += sieve[k]
            h = fnv(h, count)
            ok = ok and count == 148933
            miller_count = 0
            for k in range(300000):
                if miller_rabin(k):
                    miller_count += 1
            h = fnv(h, miller_count)
            ok = ok and miller_count == 25997
            for _ in range(20):
                mask = 0
                for exponent in EXPONENTS:
                    if lucas_lehmer(exponent):
                        mask |= 1 << exponent
                        h = fnv(h, 1)
                    else:
                        h = fnv(h, 0)
                ok = ok and mask == 2305843011361841320
        return h, ok
    return run
