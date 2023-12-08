local x = 0
local y = 0
for line in io.lines("input") do
  _, _, direction, distance = string.find(line, "(%a+) (%d+)")
  if direction == "forward" then
    x = x + distance
  elseif direction == "down" then
    y = y + distance
  elseif direction == "up" then
    y = y - distance
  end
end

print(x * y)