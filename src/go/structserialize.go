package main

type numbers struct {
	ints [16]int32
}

var serializeBuffer [72]uint8

func serializeEncode(at int32, value int32) {
	buffer := &serializeBuffer
	buffer[at] = uint8(value & 255)
	buffer[at+1] = uint8((value >> 8) & 255)
	buffer[at+2] = uint8((value >> 16) & 255)
	buffer[at+3] = uint8((value >> 24) & 255)
}

func serializeDecode(at int32) int32 {
	buffer := &serializeBuffer
	return int32(buffer[at]) | int32(buffer[at+1])<<8 | int32(buffer[at+2])<<16 | int32(buffer[at+3])<<24
}

// benchStructSerialize encodes a point and a struct of 16 int32 into a 72
// byte little endian buffer and decodes them back once per round. The
// values depend on the round number mod 2^20, so 16 times it fits an int32.
func benchStructSerialize(size int) (uint64, bool) {
	hash := uint64(fnvOffset)
	pass := true
	var p, decoded point
	var values, valuesDecoded numbers
	for round := int32(0); round < int32(size); round++ {
		value := round & 1048575
		p.horizontal = value
		p.vertical = 2 * value
		for k := int32(0); k < 16; k++ {
			values.ints[k] = 16*value + k
		}
		serializeEncode(0, p.horizontal)
		serializeEncode(4, p.vertical)
		for k := int32(0); k < 16; k++ {
			serializeEncode(8+4*k, values.ints[k])
		}
		decoded.horizontal = serializeDecode(0)
		decoded.vertical = serializeDecode(4)
		for k := int32(0); k < 16; k++ {
			valuesDecoded.ints[k] = serializeDecode(8 + 4*k)
		}
		sum := int64(decoded.horizontal) + int64(decoded.vertical)
		for k := 0; k < 16; k++ {
			sum += int64(valuesDecoded.ints[k])
		}
		hash = fnv(hash, uint64(sum))
		pass = pass && sum == 259*int64(value)+120
	}
	return hash, pass
}
