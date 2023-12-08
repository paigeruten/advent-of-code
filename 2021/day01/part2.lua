local increases = 0
local window = {}
for num in io.lines("input", "*number") do
  if #window == 4 then
    table.remove(window)
  end
  table.insert(window, 1, num)

  if #window == 4 and window[1] > window[4] then
    increases = increases + 1
  end
end

print(increases)