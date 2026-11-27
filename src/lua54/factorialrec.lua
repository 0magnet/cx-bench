-- n! for n 0 to 20 by recursion once per round.
-- zero is the 0 the compiled forms read so no compiler folds a round, see
-- README.md. It costs the same read here.
local zero = 0

return function(fnv, offset)
	local function factorial(n)
		if n == 0 then
			return 1
		end
		return n * factorial(n - 1)
	end
	return function(size)
		local h, ok = offset, true
		for _ = 1, size do
			local f = 0
			for n = 0, 20 + zero do
				f = factorial(n)
				h = fnv(h, f)
			end
			ok = ok and f == 2432902008176640000
		end
		return h, ok
	end
end
