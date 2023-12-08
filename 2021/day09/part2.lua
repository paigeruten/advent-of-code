dofile("../common.lua")

local map = {}
for line in io.lines("input") do
  table.insert(map, table.map(string.tsplit(line, ""), tonumber))
end

local low_points = {}

for y = 1, #map do
  for x = 1, #map[y] do
    height = map[y][x]
    local is_low_point =
      (not map[y][x-1] or height < map[y][x-1]) and
      (not map[y][x+1] or height < map[y][x+1]) and
      (not map[y-1] or height < map[y-1][x]) and
      (not map[y+1] or height < map[y+1][x])

    if is_low_point then
      table.insert(low_points, Vector:new(x, y))
    end
  end
end

local NEIGHBORS <const> = {
  Vector:new(-1, 0),
  Vector:new(0, 1),
  Vector:new(1, 0),
  Vector:new(0, -1)
}

local basin_sizes = {}

for _, low_point in ipairs(low_points) do
  local visited = { [low_point:to_key()] = true }
  local basin_points = {low_point}
  local idx = 1
  while basin_points[idx] do
    local p = basin_points[idx]

    for _, neighbor in ipairs(NEIGHBORS) do
      local q = p + neighbor
      local height = map[q.y] and map[q.y][q.x]
      if not visited[q:to_key()] and height and height ~= 9 then
        table.insert(basin_points, q)
        visited[q:to_key()] = true
      end
    end

    idx = idx + 1
  end

  table.insert(basin_sizes, #basin_points)
end

table.sort(basin_sizes, function(a, b) return a > b end)

print(basin_sizes[1] * basin_sizes[2] * basin_sizes[3])
