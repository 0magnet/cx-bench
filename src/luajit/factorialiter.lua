-- n! for n 0 to 20 with a loop once per round. 20! needs a uint64_t cdata, past
-- the 2^53 of a double.
-- zero is the 0 the compiled forms read so no compiler precomputes a round, see
-- README.md. It costs the same read here.
local zero = 0

return function(fnv, offset)
	local function factorial(n)
		local result = 1ULL
		for k = 2, n do
			result = result * k
		end
		return result
	end
	return function(size)
		local h, ok = offset, true
		for _ = 1, size do
			local f = 0
			for n = 0, 20 + zero do
				f = factorial(n)
				h = fnv(h, f)
			end
			ok = ok and f == 2432902008176640000ULL
		end
		return h, ok
	end
end
