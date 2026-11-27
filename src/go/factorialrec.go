package main

func factorialRecursive(n uint64) uint64 {
	if n == 0 {
		return 1
	}
	return n * factorialRecursive(n-1)
}

// benchFactorialRec takes n! for n 0 to 20 by recursion once per round.
func benchFactorialRec(size int) (uint64, bool) {
	hash := uint64(fnvOffset)
	pass := true
	for round := 0; round < size; round++ {
		var factorial uint64
		top := 20 + uint64(zero())
		for n := uint64(0); n <= top; n++ {
			factorial = factorialRecursive(n)
			hash = fnv(hash, factorial)
		}
		pass = pass && factorial == 2432902008176640000
	}
	return hash, pass
}
