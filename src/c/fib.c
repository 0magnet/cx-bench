#include "bench.h"

static int32_t fib_recursive(int32_t n) {
	if (n < 2)
		return n;
	return fib_recursive(n - 1) + fib_recursive(n - 2);
}

/* Recursive fib(25), 242,785 calls, once per round. */
uint64_t bench_fib(int64_t size, int *pass) {
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	for (int64_t round = 0; round < size; round++) {
		int32_t result = fib_recursive(25 + bench_zero);
		hash = fnv(hash, (uint64_t)result);
		ok = ok && result == 75025;
	}
	*pass = ok;
	return hash;
}
