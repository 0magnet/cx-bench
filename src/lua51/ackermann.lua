-- Ackermann(3, 5), 42,438 calls, once per round.
-- zero is the 0 the compiled forms read so no compiler precomputes a round, see
-- README.md. It costs the same read here.
local zero = 0

return function(fnv, offset)
	local function ackermann(m, n)
		if m == 0 then
			return n + 1
		end
		if n == 0 then
			return ackermann(m - 1, 1)
		end
		return ackermann(m - 1, ackermann(m, n - 1))
	end
	return function(size)
		local h, ok = offset(), true
		for _ = 1, size do
			local r = ackermann(3, 5 + zero)
			h = fnv(h, r)
			ok = ok and r == 253
		end
		return h, ok
	end
end
