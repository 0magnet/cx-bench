#include "bench.h"

/* Sums 0 to 999,999 into an int64 once per round. */
uint64_t bench_count(int64_t size, int *pass) {
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	for (int64_t round = 0; round < size; round++) {
		int64_t sum = 0;
		for (int32_t i = 0; i < 1000000; i++)
			sum += i + bench_zero;
		hash = fnv(hash, (uint64_t)sum);
		ok = ok && sum == 499999500000LL;
	}
	*pass = ok;
	return hash;
}
