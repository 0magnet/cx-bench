#include "bench.h"

static int32_t ackermann(int32_t m, int32_t n) {
	if (m == 0)
		return n + 1;
	if (n == 0)
		return ackermann(m - 1, 1);
	return ackermann(m - 1, ackermann(m, n - 1));
}

/* Ackermann(3, 5), 42,438 calls, once per round. */
uint64_t bench_ackermann(int64_t size, int *pass) {
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	for (int64_t round = 0; round < size; round++) {
		int32_t result = ackermann(3, 5 + bench_zero);
		hash = fnv(hash, (uint64_t)result);
		ok = ok && result == 253;
	}
	*pass = ok;
	return hash;
}
