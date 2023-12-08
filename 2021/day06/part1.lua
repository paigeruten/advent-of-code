dofile("../common.lua")

io.input("input")

local fishes = {}
for fish in string.gmatch(io.read("a"), "%d+") do
  table.insert(fishes, tonumber(fish))
end

for day = 1, 80 do
  local num_fishes = #fishes
  for i = 1, num_fishes do
    fishes[i] = fishes[i] - 1
    if fishes[i] == -1 then
      fishes[i] = 6
      table.insert(fishes, 8)
    end
  end
end

print(#fishes)