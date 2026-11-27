package main

func ackermann(m, n int32) int32 {
	if m == 0 {
		return n + 1
	}
	if n == 0 {
		return ackermann(m-1, 1)
	}
	return ackermann(m-1, ackermann(m, n-1))
}

// benchAckermann runs Ackermann(3, 5), 42,438 calls, once per round.
func benchAckermann(size int) (uint64, bool) {
	hash := uint64(fnvOffset)
	pass := true
	for round := 0; round < size; round++ {
		result := ackermann(3, 5)
		hash = fnv(hash, uint64(result))
		pass = pass && result == 253
	}
	return hash, pass
}
