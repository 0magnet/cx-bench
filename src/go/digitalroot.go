package main

func digitSum(n int32) int32 {
	sum := int32(0)
	for ; n > 0; n /= 10 {
		sum += n % 10
	}
	return sum
}

// benchDigitalRoot takes the digital root and additive persistence, base 10,
// of every n from 1 to 99,999 once per round. Each n folds root + 10 *
// persistence.
func benchDigitalRoot(size int) (uint64, bool) {
	hash := uint64(fnvOffset)
	pass := true
	for round := 0; round < size; round++ {
		for n := int32(1); n < 100000; n++ {
			root, persistence := n, int32(0)
			for root >= 10 {
				root = digitSum(root)
				persistence++
			}
			hash = fnv(hash, uint64(root+10*persistence))
			pass = pass && root == 1+(n-1)%9
		}
	}
	return hash, pass
}
