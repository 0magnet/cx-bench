package main

type point struct {
	horizontal int32
	vertical   int32
}

// benchStruct walks a [100]point through a pointer once per round.
func benchStruct(size int) (uint64, bool) {
	hash := uint64(fnvOffset)
	pass := true
	var points [100]point
	for i := int32(0); i < 100; i++ {
		points[i].horizontal = i
		points[i].vertical = 2 * i
	}
	for round := 0; round < size; round++ {
		sum := int32(0)
		top := 100 + zero()
		for i := int32(0); i < top; i++ {
			p := &points[i]
			sum = sum + p.horizontal + p.vertical
		}
		hash = fnv(hash, uint64(sum))
		pass = pass && sum == 14850
	}
	return hash, pass
}
