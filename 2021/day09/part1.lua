dofile("../common.lua")

local map = {}
for line in io.lines("input") do
  table.insert(map, table.map(string.tsplit(line, ""), tonumber))
end

local total_risk_level = 0

for y = 1, #map do
  for x = 1, #map[y] do
    height = map[y][x]
    local is_low_point =
      (not map[y][x-1] or height < map[y][x-1]) and
      (not map[y][x+1] or height < map[y][x+1]) and
      (not map[y-1] or height < map[y-1][x]) and
      (not map[y+1] or height < map[y+1][x])

    if is_low_point then
      local risk_level = height + 1
      total_risk_level = total_risk_level + risk_level
    end
  end
end

print(total_risk_level)
