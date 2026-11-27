#include "bench.h"

#define MEM_N 1048576
#define MEM_WALK 65536

static uint32_t mem[MEM_N];

/* Address in address, walking ones and moving inversions over a 4 MiB
   uint32 array, once per round. */
uint64_t bench_memtest(int64_t size, int *pass) {
	const uint32_t all = 0xFFFFFFFFu;
	uint64_t hash = FNV_OFFSET;
	int32_t total = 0;
	static const uint32_t patterns[4] = {0x00000000u, 0xFFFFFFFFu, 0x55555555u, 0xAAAAAAAAu};
	for (int64_t round = 0; round < size; round++) {
		uint64_t sum = 0;
		int32_t bad = 0;
		for (int32_t i = 0; i < MEM_N; i++)
			mem[i] = (uint32_t)i;
		for (int32_t i = 0; i < MEM_N; i++) {
			uint32_t read = mem[i];
			if (read != (uint32_t)i)
				bad++;
			sum += read;
		}
		for (int32_t i = 0; i < MEM_N; i++)
			mem[i] = (uint32_t)i ^ all;
		for (int32_t i = 0; i < MEM_N; i++) {
			uint32_t read = mem[i];
			if (read != ((uint32_t)i ^ all))
				bad++;
			sum += read;
		}
		hash = fnv(hash, (uint64_t)bad);
		hash = fnv(hash, sum);
		total += bad;

		for (uint32_t bit = 0; bit < 32; bit++) {
			uint32_t pattern = 1u << bit;
			bad = 0;
			sum = 0;
			for (int32_t i = 0; i < MEM_WALK; i++)
				mem[i] = pattern;
			for (int32_t i = 0; i < MEM_WALK; i++) {
				uint32_t read = mem[i];
				if (read != pattern)
					bad++;
				sum += read;
			}
			hash = fnv(hash, (uint64_t)bad);
			hash = fnv(hash, sum);
			total += bad;
		}

		for (int k = 0; k < 4; k++) {
			uint32_t pattern = patterns[k], inverse = pattern ^ all;
			bad = 0;
			sum = 0;
			for (int32_t i = 0; i < MEM_N; i++)
				mem[i] = pattern;
			for (int32_t i = 0; i < MEM_N; i++) {
				uint32_t read = mem[i];
				if (read != pattern)
					bad++;
				sum += read;
				mem[i] = inverse;
			}
			for (int32_t i = MEM_N - 1; i >= 0; i--) {
				uint32_t read = mem[i];
				if (read != inverse)
					bad++;
				sum += read;
				mem[i] = pattern;
			}
			for (int32_t i = 0; i < MEM_N; i++) {
				uint32_t read = mem[i];
				if (read != pattern)
					bad++;
				sum += read;
			}
			hash = fnv(hash, (uint64_t)bad);
			hash = fnv(hash, sum);
			total += bad;
		}
	}
	*pass = total == 0;
	return hash;
}
