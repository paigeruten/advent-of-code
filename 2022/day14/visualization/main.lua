-- run from this folder like so: `love .`

local source = {500, 0}
local source_key = "500,0"
local map = { [source_key] = "source" }
local scale = 4
local padding = 4

local min_x = source[1]
local min_y = source[2]
local max_x = source[1]
local max_y = source[2]

local floor_y
local path

function love.load()
  love.window.setMode(1400, 800)
  love.graphics.setBackgroundColor(0, 0, 0)

  for line in io.lines("input") do
    local last_x
    local last_y
    for x, y in line:gmatch("(%d+),(%d+)") do
      x, y = tonumber(x), tonumber(y)

      if x < min_x then min_x = x end
      if x > max_x then max_x = x end
      if y < min_y then min_y = y end
      if y > max_y then max_y = y end

      if x == last_x then
        for step_y = y, last_y, (last_y - y > 0 and 1 or -1) do
          map[x .. "," .. step_y] = "rock"
        end
      elseif y == last_y then
        for step_x = x, last_x, (last_x - x > 0 and 1 or -1) do
          map[step_x .. "," .. y] = "rock"
        end
      end

      last_x, last_y = x, y
    end
  end

  floor_y = max_y + 2
end

function love.update(dt)
  local x = source[1]
  local y = source[2]

  if map[source_key] == "sand" then return end

  path = {{x, y}}
  while true do
    if y + 1 == floor_y then
      map[x .. "," .. y] = "sand"
      break
    elseif map[x .. "," .. (y+1)] == nil then
      y = y + 1
    elseif map[(x-1) .. "," .. (y+1)] == nil then
      x = x - 1
      y = y + 1
    elseif map[(x+1) .. "," .. (y+1)] == nil then
      x = x + 1
      y = y + 1
    else
      map[x .. "," .. y] = "sand"
      break
    end

    table.insert(path, {x, y})
  end

  if x < min_x then min_x = x end
  if x > max_x then max_x = x end
  if y < min_y then min_y = y end
end

function love.draw()
  love.graphics.setColor(1, 0.7, 0)
  for i, sand_step in ipairs(path) do
    local x = sand_step[1]
    local y = sand_step[2]
    love.graphics.rectangle(
      "fill",
      (x - min_x + padding) * scale + 1 + 0.5,
      (y - min_y + padding) * scale + 0.5,
      2,
      2
    )
  end

  for pos, material in pairs(map) do
    local comma = string.find(pos, ",")
    local x = tonumber(string.sub(pos, 1, comma - 1))
    local y = tonumber(string.sub(pos, comma + 1, -1))

    if material == "rock" then
      love.graphics.setColor(0.75, 0.75, 0.75)
    elseif material == "sand" then
      love.graphics.setColor(1, 0.5, 0)
    elseif material == "source" then
      love.graphics.setColor(1, 0, 1)
    end

    love.graphics.rectangle(
      "fill",
      (x - min_x + padding) * scale + 0.5,
      (y - min_y + padding) * scale + 0.5,
      scale,
      scale
    )
  end

  love.graphics.setColor(0.75, 0.75, 0.75)
  love.graphics.rectangle(
    "fill",
    (padding - 1) * scale + 0.5,
    (floor_y - min_y + padding) * scale + 0.5,
    (max_x - min_x + 3) * scale,
    scale
  )
end
