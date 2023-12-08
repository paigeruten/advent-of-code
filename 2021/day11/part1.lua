dofile("../common.lua")

local NEIGHBORS <const> = {
  Vector:new(-1, -1),
  Vector:new(0, -1),
  Vector:new(1, -1),
  Vector:new(-1, 0),
  Vector:new(1, 0),
  Vector:new(-1, 1),
  Vector:new(0, 1),
  Vector:new(1, 1),
}

local map = {}
for line in io.lines("input") do
  table.insert(map, table.map(string.tsplit(line, ""), tonumber))
end

local total_flashes = 0

for step = 1, 100 do
  local to_flash = {}
  local to_flash_set = {}

  for y = 1, #map do
    for x = 1, #map[y] do
      map[y][x] = map[y][x] + 1
      if map[y][x] > 9 then
        local p = Vector:new(x, y)
        table.insert(to_flash, p)
        to_flash_set[p:to_key()] = true
      end
    end
  end

  local i = 1
  while i <= #to_flash do
    local p = to_flash[i]
    for _, neighbor in ipairs(NEIGHBORS) do
      local q = p + neighbor
      if map[q.y] and map[q.y][q.x] and not to_flash_set[q:to_key()] then
        map[q.y][q.x] = map[q.y][q.x] + 1
        if map[q.y][q.x] > 9 then
          table.insert(to_flash, q)
          to_flash_set[q:to_key()] = true
        end
      end
    end
    i = i + 1
  end

  for _, p in ipairs(to_flash) do
    map[p.y][p.x] = 0
  end

  total_flashes = total_flashes + #to_flash
end

print(total_flashes)
