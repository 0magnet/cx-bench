-- Digital root and additive persistence of every n from 1 to 99,999 once per
-- round. Each n hashes root + 10 * persistence.
return function(fnv, offset)
	local function digitSum(n)
		local sum = 0
		while n > 0 do
			sum = sum + n % 10
			n = (n - n % 10) / 10
		end
		return sum
	end
	return function(size)
		local h, ok = offset(), true
		for _ = 1, size do
			for n = 1, 99999 do
				local root, persistence = n, 0
				while root >= 10 do
					root = digitSum(root)
					persistence = persistence + 1
				end
				h = fnv(h, root + 10 * persistence)
				ok = ok and root == 1 + (n - 1) % 9
			end
		end
		return h, ok
	end
end
