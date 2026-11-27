-- Fills and reads a table of two 100,000 element arrays once per round. The
-- fill depends on the round number.
return function(fnv, offset)
	local SIZE = 100000
	local arrays = { int32s = {}, int64s = {} }
	for c = 0, SIZE - 1 do
		arrays.int32s[c], arrays.int64s[c] = 0, 0
	end
	return function(size)
		local h, ok = offset(), true
		for round = 0, size - 1 do
			local int32s, int64s = arrays.int32s, arrays.int64s
			for c = 0, SIZE - 1 do
				int32s[c] = c + round
				int64s[c] = c * 3
			end
			local sum = 0
			for c = 0, SIZE - 1 do
				sum = sum + int32s[c] + int64s[c]
			end
			h = fnv(h, sum)
			ok = ok and sum == 19999800000 + 100000 * round
		end
		return h, ok
	end
end
