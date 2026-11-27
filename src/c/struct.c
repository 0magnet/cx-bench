#include "bench.h"

struct point {
	int32_t horizontal;
	int32_t vertical;
};

/* Walks a [100]point through a pointer once per round. */
uint64_t bench_struct(int64_t size, int *pass) {
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	struct point points[100];
	for (int32_t i = 0; i < 100; i++) {
		points[i].horizontal = i;
		points[i].vertical = 2 * i;
	}
	for (int64_t round = 0; round < size; round++) {
		int32_t sum = 0, top = 100 + bench_zero;
		for (int i = 0; i < top; i++) {
			struct point *p = &points[i];
			sum = sum + p->horizontal + p->vertical;
		}
		hash = fnv(hash, (uint64_t)(int64_t)sum);
		ok = ok && sum == 14850;
	}
	*pass = ok;
	return hash;
}
