dofile("../common.lua")

local DIRECTIONS <const> = {
  Vector:new(0, 1),
  Vector:new(1, 0),
  Vector:new(0, -1),
  Vector:new(-1, 0),
}

local map = {}
for line in io.lines("input") do
  table.insert(map, table.map(string.tsplit(line, ""), tonumber))
end

local unvisited = {}
local tentative_distance = {}
for y = 1, #map do
  for x = 1, #map[y] do
    local key = Vector:new(x, y):to_key()
    unvisited[key] = true
    tentative_distance[key] = math.huge
  end
end

local current = Vector:new(1, 1)
tentative_distance[current:to_key()] = 0

local destination = Vector:new(#map[#map], #map)

while true do
  for _, direction in ipairs(DIRECTIONS) do
    local neighbour = current + direction
    local neighbour_key = neighbour:to_key()
    if unvisited[neighbour_key] then
      local distance = tentative_distance[current:to_key()] + map[neighbour.y][neighbour.x]
      if distance < tentative_distance[neighbour_key] then
        tentative_distance[neighbour_key] = distance
      end
    end
  end

  unvisited[current:to_key()] = nil

  if not unvisited[destination:to_key()] then
    break
  end

  local min_distance = nil
  local min_distance_node = nil
  for node in pairs(unvisited) do
    if not min_distance or tentative_distance[node] < min_distance then
      min_distance = tentative_distance[node]
      min_distance_node = node
    end
  end

  if not min_distance_node then
    break
  end

  current = Vector:from_key(min_distance_node)
end

print(tentative_distance[destination:to_key()])
