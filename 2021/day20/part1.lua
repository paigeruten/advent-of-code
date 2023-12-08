dofile("../common.lua")

io.input("input")

local algorithm = {}
local i = 0
for char in string.chars(io.read("l")) do
  algorithm[i] = ({ ["."] = false, ["#"] = true })[char]
  i = i + 1
end

assert(io.read("l") == "")

local is_light_outside = false
local image = {}
local min_x, min_y, max_x, max_y
local y = 1
while true do
  local line = io.read("l")
  if not line then break end
  for x = 1, #line do
    image[Vector:new(x, y):to_key()] = ({ ["."] = false, ["#"] = true })[string.sub(line, x, x)]

    if not min_x or x < min_x then min_x = x end
    if not min_y or y < min_y then min_y = y end
    if not max_x or x > max_x then max_x = x end
    if not max_y or y > max_y then max_y = y end
  end
  y = y + 1
end

local NEIGHBORS <const> = {
  Vector:new(-1, -1),
  Vector:new(0, -1),
  Vector:new(1, -1),
  Vector:new(-1, 0),
  Vector:new(0, 0),
  Vector:new(1, 0),
  Vector:new(-1, 1),
  Vector:new(0, 1),
  Vector:new(1, 1),
}

for step = 1, 2 do
  local new_image = {}
  local new_is_light_outside = ({ [true] = algorithm[511], [false] = algorithm[0] })[is_light_outside]

  min_x = min_x - 1
  min_y = min_y - 1
  max_x = max_x + 1
  max_y = max_y + 1

  for x = min_x, max_x do
    for y = min_y, max_y do
      local pos = Vector:new(x, y)

      local enhancement_code = ""
      for _, delta in ipairs(NEIGHBORS) do
        local neighbor = pos + delta
        if image[neighbor:to_key()] == true then
          enhancement_code = enhancement_code .. "1"
        elseif image[neighbor:to_key()] == false then
          enhancement_code = enhancement_code .. "0"
        else
          enhancement_code = enhancement_code .. (is_light_outside and "1" or "0")
        end
      end

      local enhanced_pixel = algorithm[tonumber(enhancement_code, 2)]

      new_image[Vector:new(x, y):to_key()] = enhanced_pixel
    end
  end

  image, is_light_outside = new_image, new_is_light_outside
end

local num_lit = 0
for x = min_x, max_x do
  for y = min_y, max_y do
    if image[Vector:new(x, y):to_key()] then
      num_lit = num_lit + 1
    end
  end
end

print(num_lit)
