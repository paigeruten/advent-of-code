local increases = 0
local prev_num = nil
for num in io.lines("input", "*number") do
  if prev_num and num > prev_num then
    increases = increases + 1
  end

  prev_num = num
end

print(increases)