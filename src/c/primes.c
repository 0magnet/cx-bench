#include "bench.h"

#define SIEVE_N 2000000

static int32_t sieve[SIEVE_N];

static uint64_t pow_mod(uint64_t base, uint64_t exponent, uint64_t modulus) {
	uint64_t result = 1, power = base % modulus;
	for (; exponent > 0; exponent >>= 1) {
		if (exponent & 1)
			result = result * power % modulus;
		power = power * power % modulus;
	}
	return result;
}

static int witness(uint64_t a, uint64_t d, uint64_t s, uint64_t n) {
	int composite = 0;
	if (a % n != 0) {
		uint64_t x = pow_mod(a, d, n);
		if (x != 1 && x != n - 1) {
			composite = 1;
			for (uint64_t r = 1; r < s && composite; r++) {
				x = x * x % n;
				if (x == n - 1)
					composite = 0;
			}
		}
	}
	return composite;
}

static int miller_rabin(uint64_t n) {
	if (n < 2)
		return 0;
	if (n % 2 == 0)
		return n == 2;
	uint64_t d = n - 1, s = 0;
	while (d % 2 == 0) {
		d /= 2;
		s++;
	}
	return !witness(2, d, s, n) && !witness(7, d, s, n) && !witness(61, d, s, n);
}

static uint64_t mul_mod(uint64_t x, uint64_t y, uint64_t modulus) {
	uint64_t result = 0, addend = x % modulus;
	for (; y > 0; y >>= 1) {
		if (y & 1) {
			result += addend;
			if (result >= modulus)
				result -= modulus;
		}
		addend += addend;
		if (addend >= modulus)
			addend -= modulus;
	}
	return result;
}

static int lucas_lehmer(uint64_t exponent) {
	uint64_t modulus = (1ULL << exponent) - 1, s = 4;
	for (uint64_t i = 0; i < exponent - 2; i++) {
		s = mul_mod(s, s, modulus);
		s = (s + modulus - 2) % modulus;
	}
	return s == 0;
}

/* Sieve below 2,000,000, Miller-Rabin below 300,000 and Lucas-Lehmer 20
   times for the odd prime exponents 3 to 61, once per round. */
uint64_t bench_primes(int64_t size, int *pass) {
	static const uint64_t exponents[17] = {3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61};
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	for (int64_t round = 0; round < size; round++) {
		for (int32_t i = 2; i < SIEVE_N; i++)
			sieve[i] = 1;
		for (int32_t i = 2; i * i < SIEVE_N; i++)
			if (sieve[i] == 1)
				for (int32_t j = i * i; j < SIEVE_N; j += i)
					sieve[j] = 0;
		int32_t count = 0;
		for (int32_t i = 2; i < SIEVE_N; i++)
			count += sieve[i];
		hash = fnv(hash, (uint64_t)count);
		ok = ok && count == 148933;

		int32_t miller_count = 0;
		for (uint64_t k = 0; k < 300000; k++)
			if (miller_rabin(k))
				miller_count++;
		hash = fnv(hash, (uint64_t)miller_count);
		ok = ok && miller_count == 25997;

		for (int repeat = 0; repeat < 20; repeat++) {
			uint64_t mask = 0;
			for (int e = 0; e < 17; e++) {
				if (lucas_lehmer(exponents[e])) {
					mask |= 1ULL << exponents[e];
					hash = fnv(hash, 1);
				} else {
					hash = fnv(hash, 0);
				}
			}
			ok = ok && mask == 2305843011361841320ULL;
		}
	}
	*pass = ok;
	return hash;
}
