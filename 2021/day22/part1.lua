dofile("../common.lua")

local cubes = {}
for line in io.lines("input") do
  local matches = table.pack(string.match(
    line,
    "(%l+) x=(%-?%d+)%.%.(%-?%d+),y=(%-?%d+)%.%.(%-?%d+),z=(%-?%d+)%.%.(%-?%d+)"
  ))
  if #matches ~= 0 then
    local on_off = table.remove(matches, 1)
    local x1, x2, y1, y2, z1, z2 = table.unpack(table.map(matches, tonumber))

    if x1 <= 50 and x2 >= -50 and y1 <= 50 and y2 >= -50 and z1 <= 50 and z2 >= -50 then
      x1, x2 = math.max(x1, -50), math.min(x2, 50)
      y1, y2 = math.max(y1, -50), math.min(y2, 50)
      z1, z2 = math.max(z1, -50), math.min(z2, 50)

      for x = x1, x2 do
        for y = y1, y2 do
          for z = z1, z2 do
            cubes[string.join({x, y, z}, ",")] = (on_off == "on" and true or nil)
          end
        end
      end
    end
  end
end

local num_cubes = 0
for _ in pairs(cubes) do
  num_cubes = num_cubes + 1
end

print(num_cubes)
