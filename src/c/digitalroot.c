#include "bench.h"

static int32_t digit_sum(int32_t n) {
	int32_t sum = 0;
	for (; n > 0; n /= 10)
		sum += n % 10;
	return sum;
}

/* Digital root and additive persistence of every n from 1 to 99,999 once
   per round. Each n folds root + 10 * persistence. */
uint64_t bench_digitalroot(int64_t size, int *pass) {
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	for (int64_t round = 0; round < size; round++) {
		for (int32_t n = 1; n < 100000; n++) {
			int32_t root = n, persistence = 0;
			while (root >= 10) {
				root = digit_sum(root);
				persistence++;
			}
			hash = fnv(hash, (uint64_t)(root + 10 * persistence));
			ok = ok && root == 1 + (n - 1) % 9;
		}
	}
	*pass = ok;
	return hash;
}
