-- Bubble sorts a reversed array of 150 once per round.
return function(fnv, offset)
	return function(size)
		local h, ok = offset(), true
		local nums = {}
		for i = 0, 149 do
			nums[i] = 0
		end
		for _ = 1, size do
			for i = 0, 149 do
				nums[i] = 150 - i
			end
			local swaps = 0
			for i = 0, 148 do
				for j = 1, 149 - i do
					local a, b = nums[j - 1], nums[j]
					if a > b then
						nums[j - 1], nums[j] = b, a
						swaps = swaps + 1
					end
				end
			end
			h = fnv(h, swaps)
			ok = ok and swaps == 11175
		end
		for i = 0, 149 do
			h = fnv(h, nums[i])
			ok = ok and (size == 0 or nums[i] == i + 1)
		end
		return h, ok
	end
end
