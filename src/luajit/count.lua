-- Sums 0 to 999,999 once per round.
-- zero is the 0 the compiled forms read so no compiler precomputes a round, see
-- README.md. It costs the same read here.
local zero = 0

return function(fnv, offset)
	return function(size)
		local h, ok = offset, true
		for _ = 1, size do
			local sum = 0
			for i = 0, 999999 do
				sum = sum + i + zero
			end
			h = fnv(h, sum)
			ok = ok and sum == 499999500000
		end
		return h, ok
	end
end
