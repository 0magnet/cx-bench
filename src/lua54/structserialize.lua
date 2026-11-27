-- Encodes a point and 16 int32 into a 72 byte little endian buffer and
-- decodes them back once per round. The values depend on the round mod 2^20.
return function(fnv, offset)
	local buffer = {}
	for i = 0, 71 do
		buffer[i] = 0
	end
	local function encode(at, value)
		buffer[at] = value & 255
		buffer[at + 1] = (value >> 8) & 255
		buffer[at + 2] = (value >> 16) & 255
		buffer[at + 3] = (value >> 24) & 255
	end
	local function decode(at)
		local v = buffer[at] | buffer[at + 1] << 8 | buffer[at + 2] << 16 | buffer[at + 3] << 24
		if v >= 0x80000000 then
			v = v - 0x100000000
		end
		return v
	end
	return function(size)
		local h, ok = offset, true
		local point, decoded = { horizontal = 0, vertical = 0 }, { horizontal = 0, vertical = 0 }
		local ints, decodedInts = {}, {}
		for round = 0, size - 1 do
			local value = round & 1048575
			point.horizontal = value
			point.vertical = 2 * value
			for k = 0, 15 do
				ints[k] = 16 * value + k
			end
			encode(0, point.horizontal)
			encode(4, point.vertical)
			for k = 0, 15 do
				encode(8 + 4 * k, ints[k])
			end
			decoded.horizontal = decode(0)
			decoded.vertical = decode(4)
			for k = 0, 15 do
				decodedInts[k] = decode(8 + 4 * k)
			end
			local sum = decoded.horizontal + decoded.vertical
			for k = 0, 15 do
				sum = sum + decodedInts[k]
			end
			h = fnv(h, sum)
			ok = ok and sum == 259 * value + 120
		end
		return h, ok
	end
end
