dofile("../common.lua")

-- found the answer by playing with it: the velocity that gives you the highest
-- y position is (-target.min.y) - 1. (x velocity doesn't really matter)
local target = { min = Vector:new(25, -260), max = Vector:new(67, -200) }

local position = Vector:new(0, 0)
local velocity = Vector:new(tonumber(arg[1] or 7), tonumber(arg[2] or 2))

io.write("initial velocity: x=" .. velocity.x .. ", y=" .. velocity.y .. "\n")

local function hit(pos, target)
    return pos.x >= target.min.x
       and pos.x <= target.max.x
       and pos.y >= target.min.y
       and pos.y <= target.max.y
end

local visited = {}
visited[position:to_key()] = true

while true do
  position = position + velocity
  visited[position:to_key()] = true

  if hit(position, target) or position.x > target.max.x or position.y < target.min.y then
    break
  end

  if velocity.x > 0 then velocity.x = velocity.x - 1 end
  if velocity.x < 0 then velocity.x = velocity.x + 1 end

  velocity.y = velocity.y - 1
end

local x_history = table.map(
  table.keys(visited),
  function (pos) return Vector:from_key(pos).x end
)
local y_history = table.map(
  table.keys(visited),
  function (pos) return Vector:from_key(pos).y end
)

local min_x = math.min(target.min.x, table.unpack(x_history))
local max_x = math.max(target.max.x, table.unpack(x_history))
local min_y = math.min(target.min.y, table.unpack(y_history))
local max_y = math.max(target.max.y, table.unpack(y_history))

for y = max_y, min_y, -1 do
  for x = min_x, max_x do
    if visited[Vector:new(x, y):to_key()] then
      io.write("#")
    elseif hit(Vector:new(x, y), target) then
      io.write("T")
    else
      io.write(".")
    end
  end
  io.write("\n")
end

io.write("max y: " .. max_y .. "\n")
