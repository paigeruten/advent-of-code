-- terminology for this was confusing, so.. here's a guide:
--
--   digit: a set of segment/wire labels, like 'abdfg'
--   numeral: the numeric value displayed by a digit, like '5'
--   segment: a letter representing a particular segment of a digit, like 'f'
--   wire: a letter representing the wire hooked up to a (possibly non-matching) segment, like 'd'
--   letter: a segment or a wire

dofile("../common.lua")

-- the numeral for each (decoded) digit (letters must be sorted in order to look these up)
local DIGIT_NUMERALS <const> = {
  abcefg = 0, cf = 1, acdeg = 2, acdfg = 3, bcdf = 4,
  abdfg = 5, abdefg = 6, acf = 7, abcdefg = 8, abcdfg = 9
}

-- segments that are shared by all digits of length K
local COMMON_SEGMENTS_BY_DIGIT_LENGTH <const> = {
  [2] = "cf", [3] = "acf", [4] = "bcdf",
  [5] = "adg", [6] = "abfg", [7] = "abcdefg"
}

-- returns letters that appear in every digit (like a set intersection)
local function letters_in_common(digits)
  local letter_counts = {}
  for _, digit in ipairs(digits) do
    for letter in string.gmatch(digit, ".") do
      letter_counts[letter] = (letter_counts[letter] or 0) + 1
    end
  end

  local common_letters = {}
  for letter, count in pairs(letter_counts) do
    if count == #digits then
      table.insert(common_letters, letter)
    end
  end

  return common_letters
end

-- removes letters from `digit`
local function subtract_letters(digit, letters_to_remove)
  return string.gsub(digit, "[" .. letters_to_remove .. "]", "")
end

-- returns all valid segment letters that aren't in `digit`.
local function flip_letters(digit)
  return subtract_letters("abcdefg", digit)
end

local function decode_digits(pattern_digits, output_digits)
  -- keeps track of possible segments each wire could be connected to.
  -- the goal is to narrow these down to one segment each.
  local wire_to_segment_mapping = {
    a = "abcdefg", b = "abcdefg", c = "abcdefg", d = "abcdefg",
    e = "abcdefg", f = "abcdefg", g = "abcdefg"
  }

  -- group pattern digits by their length (# of segments)
  local pattern_digits_by_length = {}
  for _, digit in ipairs(pattern_digits) do
    pattern_digits_by_length[#digit] = pattern_digits_by_length[#digit] or {}
    table.insert(pattern_digits_by_length[#digit], digit)
  end

  -- for each group of pattern digits N segments long, use the wires they have
  -- in common to narrow down the possible segments those wires are connected to.
  for len, pattern_digits in pairs(pattern_digits_by_length) do
    local segments_to_remove = flip_letters(COMMON_SEGMENTS_BY_DIGIT_LENGTH[len])
    if #segments_to_remove > 0 then
      for _, wire in ipairs(letters_in_common(pattern_digits)) do
        wire_to_segment_mapping[wire] = subtract_letters(
          wire_to_segment_mapping[wire],
          segments_to_remove
        )
      end
    end
  end

  -- the rest can be solved by simple deduction
  while true do
    -- find all wires that we've narrowed down to a single possible segment
    local solved_segments = ""
    for wire, possible_segments in pairs(wire_to_segment_mapping) do
      if #possible_segments == 1 then
        solved_segments = solved_segments .. possible_segments
      end
    end

    -- solved all of them?
    if #solved_segments == 7 then break end

    -- remove each solved segment from other wires' possible segments
    for wire, possible_segments in pairs(wire_to_segment_mapping) do
      if #possible_segments > 1 then
        wire_to_segment_mapping[wire] = subtract_letters(possible_segments, solved_segments)
      end
    end
  end

  -- wire_to_segment_mapping now maps each wire to a single segment.
  -- we can pass the mapping table directly into string.gsub to decode a digit.
  -- we then sort the digit's letters so we can look up the numeral in DIGIT_NUMERALS.
  local output_numerals = ""
  for _, digit in ipairs(output_digits) do
    local decoded_digit = string.gsub(digit, ".", wire_to_segment_mapping)
    local decoded_digit_letters = {}
    for i = 1, #decoded_digit do
      table.insert(decoded_digit_letters, string.sub(decoded_digit, i, i))
    end
    table.sort(decoded_digit_letters)

    local numeral = DIGIT_NUMERALS[table.concat(decoded_digit_letters)]
    output_numerals = output_numerals .. numeral
  end

  return tonumber(output_numerals)
end

-- solve the problem for each line in the input, keeping track of the total.
local output_total = 0
for line in io.lines("input") do
  local pattern_digits_str, output_digits_str = string.split(line, "|")

  if pattern_digits_str and output_digits_str then
    local pattern_digits = string.scan(pattern_digits_str, "[a-g]+")
    local output_digits = string.scan(output_digits_str, "[a-g]+")

    local output = decode_digits(pattern_digits, output_digits)
    output_total = output_total + output
  end
end

print(output_total)
