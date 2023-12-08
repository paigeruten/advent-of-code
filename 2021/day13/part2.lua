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

for _, fold in ipairs(folds) do
  local axis, fold_at = fold.axis, fold.fold_at

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

  dots = next_dots
end

local min_x, min_y, max_x, max_y
for dotstr in pairs(dots) do
  local dot = Vector:from_key(dotstr)

  if not min_x or dot.x < min_x then min_x = dot.x end
  if not min_y or dot.y < min_y then min_y = dot.y end
  if not max_x or dot.x > max_x then max_x = dot.x end
  if not max_y or dot.y > max_y then max_y = dot.y end
end

for y = min_y, max_y do
  for x = min_x, max_x do
    if dots[Vector:new(x, y):to_key()] then
      io.write("#")
    else
      io.write(" ")
    end
  end
  io.write("\n")
end
