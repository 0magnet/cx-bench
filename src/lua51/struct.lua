-- Walks 100 points, tables of two fields, once per round.
-- zero is the 0 the compiled forms read so no compiler folds a round, see
-- README.md. It costs the same read here.
local zero = 0

return function(fnv, offset)
	return function(size)
		local h, ok = offset(), true
		local points = {}
		for i = 0, 99 do
			points[i] = { horizontal = i, vertical = 2 * i }
		end
		for _ = 1, size do
			local sum = 0
			for i = 0, 99 + zero do
				local p = points[i]
				sum = sum + p.horizontal + p.vertical
			end
			h = fnv(h, sum)
			ok = ok and sum == 14850
		end
		return h, ok
	end
end
