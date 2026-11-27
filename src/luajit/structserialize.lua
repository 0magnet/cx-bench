-- Encodes a point and 16 int32 into a 72 byte little endian buffer and
-- decodes them back once per round. The values depend on the round mod 2^20. The
-- bit library returns signed 32 bit values, as decode needs.
local bit = require("bit")

return function(fnv, offset)
	local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift
	local buffer = {}
	for i = 0, 71 do
		buffer[i] = 0
	end
	local function encode(at, value)
		buffer[at] = band(value, 255)
		buffer[at + 1] = band(rshift(value, 8), 255)
		buffer[at + 2] = band(rshift(value, 16), 255)
		buffer[at + 3] = band(rshift(value, 24), 255)
	end
	local function decode(at)
		return bor(buffer[at], lshift(buffer[at + 1], 8), lshift(buffer[at + 2], 16), lshift(buffer[at + 3], 24))
	end
	return function(size)
		local h, ok = offset, true
		local point, decoded = { horizontal = 0, vertical = 0 }, { horizontal = 0, vertical = 0 }
		local ints, decodedInts = {}, {}
		for round = 0, size - 1 do
			local value = bit.band(round, 1048575)
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
