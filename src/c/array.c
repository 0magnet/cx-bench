#include "bench.h"

/* Bubble sorts a reversed array of 150 once per round. */
uint64_t bench_array(int64_t size, int *pass) {
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	int32_t nums[150] = {0};
	for (int64_t round = 0; round < size; round++) {
		for (int32_t i = 0; i < 150; i++)
			nums[i] = 150 - i;
		int32_t swaps = 0;
		for (int32_t i = 0; i < 149; i++)
			for (int32_t j = 1; j < 150 - i; j++)
				if (nums[j - 1] > nums[j]) {
					int32_t t = nums[j - 1];
					nums[j - 1] = nums[j];
					nums[j] = t;
					swaps++;
				}
		hash = fnv(hash, (uint64_t)swaps);
		ok = ok && swaps == 11175;
	}
	for (int32_t i = 0; i < 150; i++) {
		hash = fnv(hash, (uint64_t)(int64_t)nums[i]);
		ok = ok && (size == 0 || nums[i] == i + 1);
	}
	*pass = ok;
	return hash;
}
