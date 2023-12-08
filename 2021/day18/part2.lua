dofile("../common.lua")

local function tokenize_snumber(str)
  local snumber = {}
  for char in string.chars(str) do
    if char == "[" or char == "]" then
      table.insert(snumber, char)
    elseif string.match(char, "%d") then
      table.insert(snumber, tonumber(char))
    end
  end
  return snumber
end

local function explode_snumber(snumber)
  local i = 1
  local depth = 0
  local prev_number_idx = nil
  while snumber[i] do
    if snumber[i] == "[" then
      if depth == 4 then
        assert(type(snumber[i + 1]) == "number")
        assert(type(snumber[i + 2]) == "number")
        assert(snumber[i + 3] == "]")

        local left_num, right_num = snumber[i + 1], snumber[i + 2]

        if prev_number_idx then
          snumber[prev_number_idx] = snumber[prev_number_idx] + left_num
        end

        local next_number_idx = i + 4
        while snumber[next_number_idx] do
          if type(snumber[next_number_idx]) == "number" then
            snumber[next_number_idx] = snumber[next_number_idx] + right_num
            break
          end
          next_number_idx = next_number_idx + 1
        end

        table.remove(snumber, i)
        table.remove(snumber, i)
        table.remove(snumber, i)
        snumber[i] = 0

        return true
      end

      depth = depth + 1
    elseif snumber[i] == "]" then
      depth = depth - 1
    elseif type(snumber[i]) == "number" then
      prev_number_idx = i
    end

    i = i + 1
  end

  return false
end

local function split_snumber(snumber)
  local i = 1
  while snumber[i] do
    if type(snumber[i]) == "number" and snumber[i] >= 10 then
      local num = snumber[i]
      local left_num, right_num = math.floor(num / 2), math.ceil(num / 2)

      table.remove(snumber, i)
      table.insert(snumber, i, "[")
      table.insert(snumber, i + 1, left_num)
      table.insert(snumber, i + 2, right_num)
      table.insert(snumber, i + 3, "]")

      return true
    end

    i = i + 1
  end

  return false
end

local function reduce_snumber(snumber)
  while true do
    if not explode_snumber(snumber) then
      if not split_snumber(snumber) then
        break
      end
    end
  end
end

local function add_snumbers(a, b)
  local sum = {}
  table.insert(sum, "[")
  for _, value in ipairs(a) do
    table.insert(sum, value)
  end
  for _, value in ipairs(b) do
    table.insert(sum, value)
  end
  table.insert(sum, "]")
  reduce_snumber(sum)
  return sum
end

local function treeify_snumber(snumber)
  local str = string.join(snumber, ",")
  str = string.gsub(str, "%[", "{")
  str = string.gsub(str, "%]", "}")
  str = string.gsub(str, "{,", "{")
  return assert(load("return " .. str))()
end

local function snumber_tree_magnitude(snumber)
  if type(snumber) == "number" then return snumber end

  return 3 * snumber_tree_magnitude(snumber[1])
       + 2 * snumber_tree_magnitude(snumber[2])
end

local function snumber_magnitude(snumber)
  return snumber_tree_magnitude(treeify_snumber(snumber))
end

local snumbers = {}
for line in io.lines("input") do
  table.insert(snumbers, tokenize_snumber(line))
end

local max_magnitude = nil
for i, snumber1 in ipairs(snumbers) do
  for j, snumber2 in ipairs(snumbers) do
    if i ~= j then
      local magnitude_of_sum = snumber_magnitude(add_snumbers(snumber1, snumber2))
      if not max_magnitude or magnitude_of_sum > max_magnitude then
        max_magnitude = magnitude_of_sum
      end
    end
  end
end

print(max_magnitude)
