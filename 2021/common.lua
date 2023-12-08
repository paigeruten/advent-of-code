function table.empty(t)
  return next(t) == nil
end

function table.clone(t)
  return {table.unpack(t)}
end

function table.inspect(t, level)
  level = level or 0
  local indent = string.rep("  ", level)

  local buf = {}
  if level == 0 then buf[#buf+1] = indent .. "{\n" end

  for k, v in pairs(t) do
    buf[#buf+1] = indent .. "  "

    if type(k) == "string" and string.match(k, "%s") then
      buf[#buf+1] = string.format("[%q]", k)
    elseif type(k) == "string" then
      buf[#buf+1] = k
    else
      buf[#buf+1] = "[" .. tostring(k) .. "]"
    end

    buf[#buf+1] = " = "

    if type(v) == "table" and table.empty(v) then
      buf[#buf+1] = "{}"
    elseif type(v) == "table" then
      buf[#buf+1] = "{\n"
      buf[#buf+1] = table.inspect(v, level + 1)
      buf[#buf+1] = indent .. "  }"
    elseif type(v) == "string" then
      buf[#buf+1] = string.format("%q", v)
    else
      buf[#buf+1] = tostring(v)
    end

    buf[#buf+1] = "\n"
  end

  if level == 0 then buf[#buf+1] = indent .. "}\n" end

  return table.concat(buf)
end

function table.print(t)
  io.stdout:write(table.inspect(t))
end

function table.partition(t, predicate)
  local yeses = {}
  local nos = {}
  for _, value in ipairs(t) do
    if predicate(value) then
      table.insert(yeses, value)
    else
      table.insert(nos, value)
    end
  end
  return yeses, nos
end

function table.includes(t, x)
  for _, value in pairs(t) do
    if value == x then return true end
  end
  return false
end

function table.map(t, fn)
  local results = {}
  for k, v in pairs(t) do
    results[k] = fn(v)
  end
  return results
end

function table.keys(t)
  local results = {}
  for key in pairs(t) do
    table.insert(results, key)
  end
  return results
end

function table.values(t)
  local results = {}
  for _, value in pairs(t) do
    table.insert(results, value)
  end
  return results
end

function table.reduce(t, fn, init)
  local acc = init
  for _, v in pairs(t) do
    acc = fn(acc, v)
  end
  return acc
end

function string.tsplit(str, pattern)
  if str == "" then return {} end

  pattern = pattern or "%s+"

  if pattern == "" then
    local parts = {}
    for char in string.gmatch(str, ".") do
      table.insert(parts, char)
    end
    return parts
  end

  local parts = {}
  local index = 1
  while true do
    if index > #str then
      table.insert(parts, "")
      break
    end

    local i, j = string.find(str, pattern, index)

    if not i then
      table.insert(parts, string.sub(str, index))
      break
    end

    if i == index then
      table.insert(parts, "")
    else
      table.insert(parts, string.sub(str, index, i - 1))
    end

    index = j + 1
  end

  return parts
end

function string.split(str, pattern)
  return table.unpack(string.tsplit(str, pattern))
end

function string.scan(str, pattern)
  local matches = {}
  for match in string.gmatch(str, pattern) do
    table.insert(matches, match)
  end
  return matches
end

function string.chars(str)
  local state = { index = 1 }
  local function iterator(state)
    if state.index <= #str then
      state.index = state.index + 1
      return string.sub(str, state.index - 1, state.index - 1)
    end
    return nil
  end

  return iterator, state
end

function string.join(t, sep)
  if not sep then return table.concat(t) end

  local table_with_seps = {}
  for i, v in ipairs(t) do
    table.insert(table_with_seps, v)
    if i ~= #t then
      table.insert(table_with_seps, sep)
    end
  end

  return table.concat(table_with_seps)
end

Vector = {}
Vector.__index = Vector

function Vector:new(x, y)
  local vector = { x = x, y = y }
  setmetatable(vector, self)
  return vector
end

function Vector:to_key()
  return self.x .. "," .. self.y
end

function Vector:from_key(key)
  local x, y = string.match(key, "^(%-?%d+),(%-?%d+)$")
  if x then
    return Vector:new(tonumber(x), tonumber(y))
  else
    return nil
  end
end

function Vector.__add(a, b)
  return Vector:new(a.x + b.x, a.y + b.y)
end

