-- Count '1' bits in each column
local ones = {}
local count = 0
for line in io.lines("input") do
  local bits = string.reverse(string.gsub(line, "%s+", ""))
  if string.match(bits, "^[01]+$") then
    for i = 1,#bits do
      ones[i] = ones[i] or 0
      if string.sub(bits, i, i) == "1" then
        ones[i] = ones[i] + 1
      end
    end

    count = count + 1
  end
end

-- Calculate gamma bits
local gamma_bits = ""
for i, num_ones in ipairs(ones) do
  -- `condition and t or f` is Lua's version of the ternary operator `condition ? t : f`
  local bit = num_ones > count / 2 and "1" or "0"
  gamma_bits = gamma_bits .. bit
end

-- Flip gamma bits to get epsilon bits
local bit_flipper = {["0"] = "1", ["1"] = "0"}
local epsilon_bits = string.gsub(gamma_bits, "[10]", bit_flipper)

-- Turn bit strings into numbers
local gamma_rate = tonumber(string.reverse(gamma_bits), 2)
local epsilon_rate = tonumber(string.reverse(epsilon_bits), 2)

-- Calculate power consumption
local power_consumption = gamma_rate * epsilon_rate
print(power_consumption)
