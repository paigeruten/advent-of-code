dofile("../common.lua")

io.input("input")

-- Keep track of number of fish that have K days left (K being the array index)
local fishes = {[0] = 0, 0, 0, 0, 0, 0, 0, 0, 0}
for fish in string.gmatch(io.read("a"), "%d+") do
  local fish_num = tonumber(fish)
  fishes[fish_num] = fishes[fish_num] + 1
end

for day = 1, 256 do
  local fishes_spawned = fishes[0]
  for i = 0, 7 do
    fishes[i] = fishes[i + 1]
  end
  fishes[8] = fishes_spawned
  fishes[6] = fishes[6] + fishes_spawned
end

local num_fishes = 0
for i = 0, 8 do
  num_fishes = num_fishes + fishes[i]
end

print(num_fishes)
