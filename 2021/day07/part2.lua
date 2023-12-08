dofile("../common.lua")

io.input("input")
local input = io.read("a")

local crabs = {}
local min_crab, max_crab
for num_str in string.gmatch(input, "%d+") do
  local num = tonumber(num_str)
  table.insert(crabs, num)

  min_crab = math.min(min_crab or num, num)
  max_crab = math.max(max_crab or num, num)
end

local function sumtorial(n)
  return n * (n+1) // 2
end

local min_fuel, min_fuel_target
for target = min_crab, max_crab do
  local fuel = 0
  for _, crab in ipairs(crabs) do
    fuel = fuel + sumtorial(math.abs(crab - target))
  end
  if not min_fuel or fuel < min_fuel then
    min_fuel = fuel
    min_fuel_target = target
  end
end

print(min_fuel)