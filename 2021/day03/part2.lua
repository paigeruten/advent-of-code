dofile('../common.lua')

local numbers = {}
for line in io.lines("input") do
  local bits = string.gsub(line, "%s+", "")
  if string.match(bits, "^[01]+$") then
    table.insert(numbers, bits)
  end
end

local function sift_numbers(numbers, chooser)
  local bit_position = 1
  while #numbers > 1 do
    ones, zeros = table.partition(numbers, function(bits)
      return string.sub(bits, bit_position, bit_position) == "1"
    end)

    numbers = chooser(ones, zeros)
    bit_position = bit_position + 1
  end
  return numbers[1]
end

local oxygen_generator_bits = sift_numbers(numbers, function(ones, zeros)
  return #ones >= #zeros and ones or zeros
end)
local co2_scrubber_bits = sift_numbers(numbers, function(ones, zeros)
  return #ones >= #zeros and zeros or ones
end)

local oxygen_generator_rating = tonumber(oxygen_generator_bits, 2)
local co2_scrubber_rating = tonumber(co2_scrubber_bits, 2)

local life_support_rating = oxygen_generator_rating * co2_scrubber_rating
print(life_support_rating)
