package main

// benchCount sums 0 to 999,999 into an int64 once per round.
func benchCount(size int) (uint64, bool) {
	hash := uint64(fnvOffset)
	pass := true
	for round := 0; round < size; round++ {
		var sum int64
		for i := int32(0); i < 1000000; i++ {
			sum += int64(i)
		}
		hash = fnv(hash, uint64(sum))
		pass = pass && sum == 499999500000
	}
	return hash, pass
}
