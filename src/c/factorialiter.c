#include "bench.h"

static uint64_t factorial_loop(uint64_t n) {
	uint64_t result = 1;
	for (uint64_t k = 2; k <= n; k++)
		result *= k;
	return result;
}

/* n! for n 0 to 20 with a loop once per round. */
uint64_t bench_factorialiter(int64_t size, int *pass) {
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	for (int64_t round = 0; round < size; round++) {
		uint64_t factorial = 0, top = 20 + (uint64_t)bench_zero;
		for (uint64_t n = 0; n <= top; n++) {
			factorial = factorial_loop(n);
			hash = fnv(hash, factorial);
		}
		ok = ok && factorial == 2432902008176640000ULL;
	}
	*pass = ok;
	return hash;
}
