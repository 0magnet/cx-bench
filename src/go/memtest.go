package main

const (
	memN    = 1048576
	memWalk = 65536
)

var memArray [memN]uint32

// benchMemtest runs address in address, walking ones and moving inversions
// over a 4 MiB uint32 array once per round.
func benchMemtest(size int) (uint64, bool) {
	const all = 0xFFFFFFFF
	hash := uint64(fnvOffset)
	total := int32(0)
	mem := &memArray
	for round := 0; round < size; round++ {
		sum := uint64(0)
		bad := int32(0)
		for i := int32(0); i < memN; i++ {
			mem[i] = uint32(i)
		}
		for i := int32(0); i < memN; i++ {
			read := mem[i]
			if read != uint32(i) {
				bad++
			}
			sum += uint64(read)
		}
		for i := int32(0); i < memN; i++ {
			mem[i] = uint32(i) ^ all
		}
		for i := int32(0); i < memN; i++ {
			read := mem[i]
			if read != uint32(i)^all {
				bad++
			}
			sum += uint64(read)
		}
		hash = fnv(hash, uint64(bad))
		hash = fnv(hash, sum)
		total += bad

		for bit := uint32(0); bit < 32; bit++ {
			pattern := uint32(1) << bit
			bad, sum = 0, 0
			for i := int32(0); i < memWalk; i++ {
				mem[i] = pattern
			}
			for i := int32(0); i < memWalk; i++ {
				read := mem[i]
				if read != pattern {
					bad++
				}
				sum += uint64(read)
			}
			hash = fnv(hash, uint64(bad))
			hash = fnv(hash, sum)
			total += bad
		}

		for _, pattern := range [4]uint32{0x00000000, 0xFFFFFFFF, 0x55555555, 0xAAAAAAAA} {
			inverse := pattern ^ all
			bad, sum = 0, 0
			for i := int32(0); i < memN; i++ {
				mem[i] = pattern
			}
			for i := int32(0); i < memN; i++ {
				read := mem[i]
				if read != pattern {
					bad++
				}
				sum += uint64(read)
				mem[i] = inverse
			}
			for i := int32(memN - 1); i >= 0; i-- {
				read := mem[i]
				if read != inverse {
					bad++
				}
				sum += uint64(read)
				mem[i] = pattern
			}
			for i := int32(0); i < memN; i++ {
				read := mem[i]
				if read != pattern {
					bad++
				}
				sum += uint64(read)
			}
			hash = fnv(hash, uint64(bad))
			hash = fnv(hash, sum)
			total += bad
		}
	}
	return hash, total == 0
}
