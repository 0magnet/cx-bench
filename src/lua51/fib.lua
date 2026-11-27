-- Recursive fib(25), 242,785 calls, once per round.
return function(fnv, offset)
	local function fib(n)
		if n < 2 then
			return n
		end
		return fib(n - 1) + fib(n - 2)
	end
	return function(size)
		local h, ok = offset(), true
		for _ = 1, size do
			local r = fib(25)
			h = fnv(h, r)
			ok = ok and r == 75025
		end
		return h, ok
	end
end
