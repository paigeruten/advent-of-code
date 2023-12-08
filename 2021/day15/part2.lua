dofile("../common.lua")

local DIRECTIONS <const> = {
  Vector:new(0, 1),
  Vector:new(1, 0),
  Vector:new(0, -1),
  Vector:new(-1, 0),
}

local function min_heap_add(heap, node, distance)
  table.insert(heap, { node = node, distance = distance })
  local idx = #heap
  local parent_idx = (idx - 1) // 2
  while idx > 0 and distance < heap[parent_idx].distance do
    heap[idx], heap[parent_idx] = heap[parent_idx], heap[idx]
    idx = parent_idx
    parent_idx = (idx - 1) // 2
  end
end

local function min_heap_extract(heap)
  local top = heap[0]
  if not top then return end

  heap[0] = heap[#heap]
  heap[#heap] = nil

  local idx = 0
  while true do
    local child_idx1, child_idx2 = idx * 2 + 1, idx * 2 + 2
    if (not heap[child_idx1] or heap[idx].distance <= heap[child_idx1].distance) and
       (not heap[child_idx2] or heap[idx].distance <= heap[child_idx2].distance) then
      break
    end

    if not heap[child_idx2] or heap[child_idx1].distance < heap[child_idx2].distance then
      heap[idx], heap[child_idx1] = heap[child_idx1], heap[idx]
      idx = child_idx1
    else
      heap[idx], heap[child_idx2] = heap[child_idx2], heap[idx]
      idx = child_idx2
    end
  end

  return top.node, top.distance
end

local first_tile = {}
for line in io.lines("input") do
  table.insert(first_tile, table.map(string.tsplit(line, ""), tonumber))
end

local map = {}
for yy = 0, 4 do
  for xx = 0, 4 do
    for y = 1, #first_tile do
      local real_y = yy * 100 + y
      map[real_y] = map[real_y] or {}
      for x = 1, #first_tile[y] do
        local real_x = xx * 100 + x
        map[real_y][real_x] = ((first_tile[y][x] + yy + xx - 1) % 9) + 1
      end
    end
  end
end

local unvisited = {}
local tentative_distance = {}
local unvisited_distance_min_heap = {}
local i = 0
for y = 1, #map do
  for x = 1, #map[y] do
    local node = Vector:new(x, y)
    unvisited[node:to_key()] = true
    if x == 1 and y == 1 then
      tentative_distance[node:to_key()] = 0
    else
      tentative_distance[node:to_key()] = math.huge
      unvisited_distance_min_heap[i] = { node = node, distance = math.huge }
      i = i + 1
    end
  end
end

local current = Vector:new(1, 1)
local destination = Vector:new(#map[#map], #map)

while true do
  for _, direction in ipairs(DIRECTIONS) do
    local neighbour = current + direction
    local neighbour_key = neighbour:to_key()
    if unvisited[neighbour_key] then
      local distance = tentative_distance[current:to_key()] + map[neighbour.y][neighbour.x]
      if distance < tentative_distance[neighbour_key] then
        tentative_distance[neighbour_key] = distance
        min_heap_add(unvisited_distance_min_heap, neighbour, distance)
      end
    end
  end

  unvisited[current:to_key()] = nil

  if not unvisited[destination:to_key()] then
    break
  end

  local min_distance_node, distance
  repeat
    min_distance_node, distance = min_heap_extract(unvisited_distance_min_heap)
  until not min_distance_node or tentative_distance[min_distance_node:to_key()] == distance

  if not min_distance_node then
    break
  end

  current = min_distance_node
end

print(tentative_distance[destination:to_key()])
