function math.cmp(a, b)
  if a < b then return -1 end
  if a > b then return 1 end
  return 0
end

local line_segments_iter = coroutine.wrap(function()
  for line in io.lines("input") do
    local x1, y1, x2, y2 = string.match(line, "(%d+),(%d+) %-> (%d+),(%d+)")
    if x1 then
      x1, y1, x2, y2 = tonumber(x1), tonumber(y1), tonumber(x2), tonumber(y2)
      coroutine.yield(x1, y1, x2, y2)
    end
  end
end)

local points = {}
for x1, y1, x2, y2 in line_segments_iter do
  local dx = math.cmp(x2, x1)
  local dy = math.cmp(y2, y1)
  local x = x1
  local y = y1
  while true do
    local point = string.format("%d,%d", x, y)
    points[point] = (points[point] or 0) + 1

    if x == x2 and y == y2 then break end

    x = x + dx
    y = y + dy
  end
end

local num_overlaps = 0
for _, count in pairs(points) do
  if count > 1 then
    num_overlaps = num_overlaps + 1
  end
end

print(num_overlaps)
