-- Sums 0 to 999,999 once per round.
return function(fnv, offset)
	return function(size)
		local h, ok = offset, true
		for _ = 1, size do
			local sum = 0
			for i = 0, 999999 do
				sum = sum + i
			end
			h = fnv(h, sum)
			ok = ok and sum == 499999500000
		end
		return h, ok
	end
end
