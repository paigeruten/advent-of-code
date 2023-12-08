local points = {}
for line in io.lines("input") do
  local x1, y1, x2, y2 = string.match(line, "(%d+),(%d+) %-> (%d+),(%d+)")
  if x1 then
    x1, y1, x2, y2 = tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
    if x1 == x2 then
      y1, y2 = math.min(y1, y2), math.max(y1, y2)
      for y = y1, y2 do
        local point = string.format("%d,%d", x1, y)
        points[point] = (points[point] or 0) + 1
      end
    elseif y1 == y2 then
      x1, x2 = math.min(x1, x2), math.max(x1, x2)
      for x = x1, x2 do
        local point = string.format("%d,%d", x, y1)
        points[point] = (points[point] or 0) + 1
      end
    end
  end
end

local num_overlaps = 0
for _, count in pairs(points) do
  if count > 1 then
    num_overlaps = num_overlaps + 1
  end
end

print(num_overlaps)
