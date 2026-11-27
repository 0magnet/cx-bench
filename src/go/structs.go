package main

const structsSize = 100000

type structsArrays struct {
	int32s [structsSize]int32
	int64s [structsSize]int64
}

var structsBenchmark structsArrays

// benchStructs fills and reads a struct of two 100,000 element arrays once
// per round. The fill depends on the round number.
func benchStructs(size int) (uint64, bool) {
	hash := uint64(fnvOffset)
	pass := true
	arrays := &structsBenchmark
	for round := int32(0); round < int32(size); round++ {
		for c := int32(0); c < structsSize; c++ {
			arrays.int32s[c] = c + round
			arrays.int64s[c] = int64(c) * 3
		}
		sum := int64(0)
		for c := int32(0); c < structsSize; c++ {
			sum = sum + int64(arrays.int32s[c]) + arrays.int64s[c]
		}
		hash = fnv(hash, uint64(sum))
		pass = pass && sum == 19999800000+100000*int64(round)
	}
	return hash, pass
}
