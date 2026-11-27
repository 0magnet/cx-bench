package main

// benchArray bubble sorts a reversed array of 150 once per round.
func benchArray(size int) (uint64, bool) {
	hash := uint64(fnvOffset)
	pass := true
	var nums [150]int32
	for round := 0; round < size; round++ {
		for i := int32(0); i < 150; i++ {
			nums[i] = 150 - i
		}
		swaps := int32(0)
		for i := int32(0); i < 149; i++ {
			for j := int32(1); j < 150-i; j++ {
				if nums[j-1] > nums[j] {
					nums[j-1], nums[j] = nums[j], nums[j-1]
					swaps++
				}
			}
		}
		hash = fnv(hash, uint64(swaps))
		pass = pass && swaps == 11175
	}
	for i := int32(0); i < 150; i++ {
		hash = fnv(hash, uint64(nums[i]))
		pass = pass && (size == 0 || nums[i] == i+1)
	}
	return hash, pass
}
