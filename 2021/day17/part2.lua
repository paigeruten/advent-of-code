dofile("../common.lua")

local function hit(pos, target)
    return pos.x >= target.min.x
       and pos.x <= target.max.x
       and pos.y >= target.min.y
       and pos.y <= target.max.y
end

local function simulate(velocity, target)
  local position = Vector:new(0, 0)
  while true do
    position = position + velocity

    if hit(position, target) then
      return true
    end

    if position.x > target.max.x or position.y < target.min.y then
      return false
    end

    if velocity.x > 0 then velocity.x = velocity.x - 1 end
    if velocity.x < 0 then velocity.x = velocity.x + 1 end

    velocity.y = velocity.y - 1
  end
end

local target = { min = Vector:new(25, -260), max = Vector:new(67, -200) }

local num_velocities = 0
for velocity_x = 1, target.max.x do
  for velocity_y = target.min.y, -target.min.y do
    if simulate(Vector:new(velocity_x, velocity_y), target) then
      num_velocities = num_velocities + 1
    end
  end
end

print(num_velocities)
