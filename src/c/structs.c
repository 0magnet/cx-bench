#include "bench.h"

#define STRUCTS_SIZE 100000

static struct {
	int32_t int32s[STRUCTS_SIZE];
	int64_t int64s[STRUCTS_SIZE];
} arrays;

/* Fills and reads a struct of two 100,000 element arrays once per round.
   The fill depends on the round number. */
uint64_t bench_structs(int64_t size, int *pass) {
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	for (int32_t round = 0; round < (int32_t)size; round++) {
		for (int32_t c = 0; c < STRUCTS_SIZE; c++) {
			arrays.int32s[c] = c + round;
			arrays.int64s[c] = (int64_t)c * 3;
		}
		int64_t sum = 0;
		for (int32_t c = 0; c < STRUCTS_SIZE; c++)
			sum = sum + arrays.int32s[c] + arrays.int64s[c];
		hash = fnv(hash, (uint64_t)sum);
		ok = ok && sum == 19999800000LL + 100000LL * round;
	}
	*pass = ok;
	return hash;
}
