local x = 0
local y = 0
local aim = 0
for line in io.lines("input") do
  _, _, direction, distance = string.find(line, "(%a+) (%d+)")
  if direction == "forward" then
    x = x + distance
    y = y + aim * distance
  elseif direction == "down" then
    aim = aim + distance
  elseif direction == "up" then
    aim = aim - distance
  end
end

print(x * y)