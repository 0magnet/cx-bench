-- Address in address, walking ones and moving inversions over 1,048,576
-- uint32 values once per round.
-- Lua 5.1 has no bit operators. With every bit of ALL set, v xor ALL is
-- ALL - v. Every sum stays below 2^53.
return function(fnv, offset)
	local N, WALK, ALL = 1048576, 65536, 0xFFFFFFFF
	local mem = {}
	for i = 0, N - 1 do
		mem[i] = 0
	end
	local patterns = { 0x00000000, 0xFFFFFFFF, 0x55555555, 0xAAAAAAAA }
	return function(size)
		local h, total = offset(), 0
		for _ = 1, size do
			local sum, bad = 0, 0
			for i = 0, N - 1 do
				mem[i] = i
			end
			for i = 0, N - 1 do
				local read = mem[i]
				if read ~= i then
					bad = bad + 1
				end
				sum = sum + read
			end
			for i = 0, N - 1 do
				mem[i] = ALL - i
			end
			for i = 0, N - 1 do
				local read = mem[i]
				if read ~= ALL - i then
					bad = bad + 1
				end
				sum = sum + read
			end
			h = fnv(fnv(h, bad), sum)
			total = total + bad
			for bit = 0, 31 do
				local pattern = 2 ^ bit
				bad, sum = 0, 0
				for i = 0, WALK - 1 do
					mem[i] = pattern
				end
				for i = 0, WALK - 1 do
					local read = mem[i]
					if read ~= pattern then
						bad = bad + 1
					end
					sum = sum + read
				end
				h = fnv(fnv(h, bad), sum)
				total = total + bad
			end
			for k = 1, 4 do
				local pattern = patterns[k]
				local inverse = ALL - pattern
				bad, sum = 0, 0
				for i = 0, N - 1 do
					mem[i] = pattern
				end
				for i = 0, N - 1 do
					local read = mem[i]
					if read ~= pattern then
						bad = bad + 1
					end
					sum = sum + read
					mem[i] = inverse
				end
				for i = N - 1, 0, -1 do
					local read = mem[i]
					if read ~= inverse then
						bad = bad + 1
					end
					sum = sum + read
					mem[i] = pattern
				end
				for i = 0, N - 1 do
					local read = mem[i]
					if read ~= pattern then
						bad = bad + 1
					end
					sum = sum + read
				end
				h = fnv(fnv(h, bad), sum)
				total = total + bad
			end
		end
		return h, total == 0
	end
end
