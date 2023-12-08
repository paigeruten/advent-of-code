dofile("../common.lua")

local dots = {}
local folds = {}
for line in io.lines("input") do
  local x, y = string.match(line, "^(%d+),(%d+)$")
  if x then
    dots[x .. "," .. y] = true
  end

  local axis, fold_at = string.match(line, "^fold along ([xy])=(%d+)$")
  if axis then
    table.insert(folds, { axis = axis, fold_at = tonumber(fold_at) })
  end
end

local axis, fold_at = folds[1].axis, folds[1].fold_at

local next_dots = {}
for dotstr in pairs(dots) do
  local dot = Vector:from_key(dotstr)
  if dot[axis] > fold_at then
    local new_dot = Vector:new(dot.x, dot.y)
    new_dot[axis] = fold_at - (dot[axis] - fold_at)
    next_dots[new_dot:to_key()] = true
  else
    next_dots[dotstr] = true
  end
end

local num_dots = 0
for _ in pairs(next_dots) do
  num_dots = num_dots + 1
end

print(num_dots)
