dofile("../common.lua")

local COMPLETION_POINTS <const> = {
  [")"] = 1,
  ["]"] = 2,
  ["}"] = 3,
  [">"] = 4,
}

local TRANSLATE_OPEN_TO_CLOSE <const> = {
  ["("] = ")",
  ["["] = "]",
  ["{"] = "}",
  ["<"] = ">",
}

local scores = {}

for line in io.lines("input") do
  local stack = {}
  local corrupted = false
  for char in string.chars(line) do
    if string.match(char, "[%[%({<]") then
      table.insert(stack, char)
    elseif string.match(char, "[%]%)}>]") then
      local expected_char = TRANSLATE_OPEN_TO_CLOSE[stack[#stack]]
      if char == expected_char then
        table.remove(stack)
      else
        corrupted = true
        break
      end
    else
      error("invalid char")
    end
  end

  if not corrupted then
    local completion_string = string.reverse(
      string.gsub(table.concat(stack), ".", TRANSLATE_OPEN_TO_CLOSE)
    )
    local completion_score = 0
    for char in string.chars(completion_string) do
      completion_score = (completion_score * 5) + COMPLETION_POINTS[char]
    end
    table.insert(scores, completion_score)
  end
end

table.sort(scores)

local middle_score = scores[(#scores + 1) // 2]
print(middle_score)
