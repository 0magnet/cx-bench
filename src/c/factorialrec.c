#include "bench.h"

static uint64_t factorial_recursive(uint64_t n) {
	if (n == 0)
		return 1;
	return n * factorial_recursive(n - 1);
}

/* n! for n 0 to 20 by recursion once per round. */
uint64_t bench_factorialrec(int64_t size, int *pass) {
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	for (int64_t round = 0; round < size; round++) {
		uint64_t factorial = 0, top = 20 + (uint64_t)bench_zero;
		for (uint64_t n = 0; n <= top; n++) {
			factorial = factorial_recursive(n);
			hash = fnv(hash, factorial);
		}
		ok = ok && factorial == 2432902008176640000ULL;
	}
	*pass = ok;
	return hash;
}
