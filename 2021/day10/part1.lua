dofile("../common.lua")

local ILLEGAL_CHAR_POINTS <const> = {
  [")"] = 3,
  ["]"] = 57,
  ["}"] = 1197,
  [">"] = 25137,
}

local TRANSLATE_OPEN_TO_CLOSE <const> = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ["<"] = ">",
}

local syntax_error_score = 0

for line in io.lines("input") do
  local stack = {}
  for char in string.chars(line) do
    if string.match(char, "[%[%({<]") then
      table.insert(stack, char)
    elseif string.match(char, "[%]%)}>]") then
      local expected_char = TRANSLATE_OPEN_TO_CLOSE[stack[#stack]]
      if char == expected_char then
        table.remove(stack)
      else
        -- corrupted line
        syntax_error_score = syntax_error_score + ILLEGAL_CHAR_POINTS[char]
        break
      end
    else
      error("invalid char")
    end
  end
end

print(syntax_error_score)