-- Encodes a point and 16 int32 into a 72 byte little endian buffer and
-- decodes them back once per round. The values depend on the round.
-- Lua 5.1 has no bit operators, so bytes come from division and modulo.
-- Every value is at least 0 when encoded.
return function(fnv, offset)
	local buffer = {}
	for i = 0, 71 do
		buffer[i] = 0
	end
	local function encode(at, value)
		buffer[at] = value % 256
		buffer[at + 1] = math.floor(value / 256) % 256
		buffer[at + 2] = math.floor(value / 65536) % 256
		buffer[at + 3] = math.floor(value / 16777216) % 256
	end
	local function decode(at)
		local v = buffer[at] + buffer[at + 1] * 256 + buffer[at + 2] * 65536 + buffer[at + 3] * 16777216
		if v >= 0x80000000 then
			v = v - 0x100000000
		end
		return v
	end
	return function(size)
		local h, ok = offset(), true
		local point, decoded = { horizontal = 0, vertical = 0 }, { horizontal = 0, vertical = 0 }
		local ints, decodedInts = {}, {}
		for round = 0, size - 1 do
			point.horizontal = round
			point.vertical = 2 * round
			for k = 0, 15 do
				ints[k] = 16 * round + k
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
			ok = ok and sum == 259 * round + 120
		end
		return h, ok
	end
end
