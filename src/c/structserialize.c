#include "bench.h"

static uint8_t buffer[72];

static void serialize_encode(int32_t at, int32_t value) {
	buffer[at] = (uint8_t)(value & 255);
	buffer[at + 1] = (uint8_t)((value >> 8) & 255);
	buffer[at + 2] = (uint8_t)((value >> 16) & 255);
	buffer[at + 3] = (uint8_t)((value >> 24) & 255);
}

static int32_t serialize_decode(int32_t at) {
	return (int32_t)((uint32_t)buffer[at] | (uint32_t)buffer[at + 1] << 8 | (uint32_t)buffer[at + 2] << 16 | (uint32_t)buffer[at + 3] << 24);
}

/* Encodes a point and 16 int32 into a 72 byte little endian buffer and
   decodes them back once per round. The values depend on the round. */
uint64_t bench_structserialize(int64_t size, int *pass) {
	uint64_t hash = FNV_OFFSET;
	int ok = 1;
	int32_t horizontal, vertical, ints[16], decoded[16];
	for (int32_t round = 0; round < (int32_t)size; round++) {
		horizontal = round;
		vertical = 2 * round;
		for (int32_t k = 0; k < 16; k++)
			ints[k] = 16 * round + k;
		serialize_encode(0, horizontal);
		serialize_encode(4, vertical);
		for (int32_t k = 0; k < 16; k++)
			serialize_encode(8 + 4 * k, ints[k]);
		int32_t decoded_horizontal = serialize_decode(0);
		int32_t decoded_vertical = serialize_decode(4);
		for (int32_t k = 0; k < 16; k++)
			decoded[k] = serialize_decode(8 + 4 * k);
		int64_t sum = (int64_t)decoded_horizontal + decoded_vertical;
		for (int k = 0; k < 16; k++)
			sum += decoded[k];
		hash = fnv(hash, (uint64_t)sum);
		ok = ok && sum == 259LL * round + 120;
	}
	*pass = ok;
	return hash;
}
