package main

func factorialLoop(n uint64) uint64 {
	result := uint64(1)
	for k := uint64(2); k <= n; k++ {
		result *= k
	}
	return result
}

// benchFactorialIter takes n! for n 0 to 20 with a loop once per round. 20!
// is the largest that fits a uint64.
func benchFactorialIter(size int) (uint64, bool) {
	hash := uint64(fnvOffset)
	pass := true
	for round := 0; round < size; round++ {
		var factorial uint64
		top := 20 + uint64(zero())
		for n := uint64(0); n <= top; n++ {
			factorial = factorialLoop(n)
			hash = fnv(hash, factorial)
		}
		pass = pass && factorial == 2432902008176640000
	}
	return hash, pass
}
