dofile("../common.lua")

local unique_segment_digits = 0
for line in io.lines("input") do
  local pattern_digits_str, output_digits_str = string.split(line, "|")

  local pattern_digits = string.scan(pattern_digits_str, "[a-g]+")
  local output_digits = string.scan(output_digits_str, "[a-g]+")

  for _, digit in ipairs(output_digits) do
    if #digit == 2 or #digit == 4 or #digit == 3 or #digit == 7 then
      unique_segment_digits = unique_segment_digits + 1
    end
  end
end

print(unique_segment_digits)
