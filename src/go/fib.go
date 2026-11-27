package main

func fibRecursive(n int32) int32 {
	if n < 2 {
		return n
	}
	return fibRecursive(n-1) + fibRecursive(n-2)
}

// benchFib runs the recursive fib(25), 242,785 calls, once per round.
func benchFib(size int) (uint64, bool) {
	hash := uint64(fnvOffset)
	pass := true
	for round := 0; round < size; round++ {
		result := fibRecursive(25)
		hash = fnv(hash, uint64(result))
		pass = pass && result == 75025
	}
	return hash, pass
}
