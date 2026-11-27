-- Sieve below 2,000,000, Miller-Rabin below 300,000 and Lucas-Lehmer 20
-- times for the odd prime exponents 3 to 61, once per round. Every value
-- stays below 2^62, so signed 64 bit integers hold them.
return function(fnv, offset)
	local SIEVE_N = 2000000
	local sieve = {}
	for i = 0, SIEVE_N - 1 do
		sieve[i] = 0
	end
	local function powMod(base, exponent, modulus)
		local result, power = 1, base % modulus
		while exponent > 0 do
			if exponent & 1 == 1 then
				result = result * power % modulus
			end
			power = power * power % modulus
			exponent = exponent >> 1
		end
		return result
	end
	local function witness(a, d, s, n)
		local composite = false
		if a % n ~= 0 then
			local x = powMod(a, d, n)
			if x ~= 1 and x ~= n - 1 then
				composite = true
				local r = 1
				while r < s and composite do
					x = x * x % n
					if x == n - 1 then
						composite = false
					end
					r = r + 1
				end
			end
		end
		return composite
	end
	local function millerRabin(n)
		if n < 2 then
			return false
		end
		if n % 2 == 0 then
			return n == 2
		end
		local d, s = n - 1, 0
		while d % 2 == 0 do
			d = d // 2
			s = s + 1
		end
		return not witness(2, d, s, n) and not witness(7, d, s, n) and not witness(61, d, s, n)
	end
	local function mulMod(x, y, modulus)
		local result, addend = 0, x % modulus
		while y > 0 do
			if y & 1 == 1 then
				result = result + addend
				if result >= modulus then
					result = result - modulus
				end
			end
			addend = addend + addend
			if addend >= modulus then
				addend = addend - modulus
			end
			y = y >> 1
		end
		return result
	end
	local function lucasLehmer(exponent)
		local modulus, s = (1 << exponent) - 1, 4
		for _ = 1, exponent - 2 do
			s = mulMod(s, s, modulus)
			s = (s + modulus - 2) % modulus
		end
		return s == 0
	end
	local exponents = { 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61 }
	return function(size)
		local h, ok = offset, true
		for _ = 1, size do
			for i = 2, SIEVE_N - 1 do
				sieve[i] = 1
			end
			local i = 2
			while i * i < SIEVE_N do
				if sieve[i] == 1 then
					for j = i * i, SIEVE_N - 1, i do
						sieve[j] = 0
					end
				end
				i = i + 1
			end
			local count = 0
			for k = 2, SIEVE_N - 1 do
				count = count + sieve[k]
			end
			h = fnv(h, count)
			ok = ok and count == 148933
			local millerCount = 0
			for k = 0, 299999 do
				if millerRabin(k) then
					millerCount = millerCount + 1
				end
			end
			h = fnv(h, millerCount)
			ok = ok and millerCount == 25997
			for _ = 1, 20 do
				local mask = 0
				for e = 1, 17 do
					local exponent = exponents[e]
					if lucasLehmer(exponent) then
						mask = mask | (1 << exponent)
						h = fnv(h, 1)
					else
						h = fnv(h, 0)
					end
				end
				ok = ok and mask == 2305843011361841320
			end
		end
		return h, ok
	end
end
