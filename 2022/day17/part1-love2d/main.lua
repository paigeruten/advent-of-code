local jets
local cur_jet = 1
local chamber = {}
local chamber_height = 0
local chamber_width = 7
local tower_height = 0
local state = "drop"
local num_fallen = 0
local cur_shape = 1
local cur_shape_x
local cur_shape_y
local shapes = {
  {
    {1,1,1,1}
  },
  {
    {0,1,0},
    {1,1,1},
    {0,1,0}
  },
  {
    {0,0,1},
    {0,0,1},
    {1,1,1}
  },
  {
    {1},
    {1},
    {1},
    {1}
  },
  {
    {1,1},
    {1,1}
  }
}

local view_width = 800
local view_height = 800
local scale = 10
local padding = 4

local erase = 0
local light_red = 1
local red = 2
local light_cyan = 3
local cyan = 4
local light_green = 5
local green = 6
local light_magenta = 7
local magenta = 8
local light_orange = 9
local orange = 10
local colors = {
  {1, 0.2, 0.2},
  {1, 0, 0},
  {0.2, 1, 1},
  {0, 1, 1},
  {0.2, 1, 0.2},
  {0, 1, 0},
  {1, 0.2, 1},
  {1, 0, 1},
  {1, 0.7, 0},
  {1, 0.5, 0}
}
local shape_colors = { red, cyan, green, magenta, orange }

function blit(shape, x, y, color)
  for sy = 1, #shape do
    for sx = 1, #shape[sy] do
      if shape[sy][sx] == 1 then
        local cy = y - (sy - 1)
        local cx = x + sx - 1
        chamber[cy] = chamber[cy] or {}
        chamber[cy][cx] = color
      end
    end
  end
  chamber_height = math.max(chamber_height, y)
end

function hasCollision(shape, x, y)
  if x < 1 or y - #shape < 0 or x + #shape[1] - 1 > chamber_width then
    return true
  end

  for sy = 1, #shape do
    for sx = 1, #shape[sy] do
      if shape[sy][sx] == 1 then
        local cy = y - (sy - 1)
        local cx = x + sx - 1
        if chamber[cy] and chamber[cy][cx] and chamber[cy][cx] > 0 and chamber[cy][cx] % 2 == 0 then
          return true
        end
      end
    end
  end

  return false
end

function love.load()
  love.window.setMode(view_width, view_height)
  love.graphics.setBackgroundColor(0, 0, 0)

  local file = io.open("input")
  jets = file:read("*all"):gsub("[^<>]", "")
  file:close()
end

function step()
  if state == "drop" then
    cur_shape_x = 3
    cur_shape_y = tower_height + 3 + #shapes[cur_shape]
    blit(shapes[cur_shape], cur_shape_x, cur_shape_y, shape_colors[cur_shape] - 1)

    state = "jet"
  elseif state == "jet" then
    local dx = ({ ["<"] = -1, [">"] = 1 })[jets:sub(cur_jet, cur_jet)]

    if not hasCollision(shapes[cur_shape], cur_shape_x + dx, cur_shape_y) then
      blit(shapes[cur_shape], cur_shape_x, cur_shape_y, erase)
      cur_shape_x = cur_shape_x + dx
      blit(shapes[cur_shape], cur_shape_x, cur_shape_y, shape_colors[cur_shape] - 1)
    end

    cur_jet = cur_jet == #jets and 1 or cur_jet + 1
    state = "fall"
  elseif state == "fall" then
    if hasCollision(shapes[cur_shape], cur_shape_x, cur_shape_y - 1) then
      blit(shapes[cur_shape], cur_shape_x, cur_shape_y, shape_colors[cur_shape])

      num_fallen = num_fallen + 1
      tower_height = math.max(tower_height, cur_shape_y)
      cur_shape = cur_shape == #shapes and 1 or cur_shape + 1
      state = "drop"
    else
      blit(shapes[cur_shape], cur_shape_x, cur_shape_y, erase)
      cur_shape_y = cur_shape_y - 1
      blit(shapes[cur_shape], cur_shape_x, cur_shape_y, shape_colors[cur_shape] - 1)

      state = "jet"
    end
  end
end

local speed = 1
local frame = 1
local paused = false
function love.update(dt)
  if paused then return end

  if speed > 0 then
    for i = 1, speed do step() end
  elseif frame % -(speed - 2) == 0 then
    step()
  end

  frame = frame + 1
end

function love.keypressed(key, scancode, isrepeat)
  if scancode == "right" then
    speed = speed + 1
  elseif scancode == "left" then
    speed = speed - 1
  elseif scancode == "up" then
    scale = scale + 1
  elseif scancode == "down" and scale > 1 then
    scale = scale - 1
  elseif scancode == "space" then
    paused = not paused
  end
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print(
    "Blocks fallen: " .. num_fallen .. "     Tower height: " .. tower_height .. "     Speed: " .. speed .. " (left/right arrow keys)     Scale: " .. scale .. " (up/down arrow keys)",
    10,
    10
  )

  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.rectangle(
    "fill",
    padding * scale + 0.5,
    padding * scale + 0.5,
    (chamber_width + 1) * scale,
    chamber_height * scale
  )

  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.rectangle(
    "fill",
    padding * scale + 0.5,
    (chamber_height + padding) * scale + 0.5,
    (chamber_width + 2) * scale,
    scale
  )
  love.graphics.rectangle(
    "fill",
    padding * scale + 0.5,
    padding * scale + 0.5,
    scale,
    chamber_height * scale
  )
  love.graphics.rectangle(
    "fill",
    (padding + chamber_width + 1) * scale + 0.5,
    padding * scale + 0.5,
    scale,
    chamber_height * scale
  )

  for cy = 1, chamber_height do
    local real_y = (chamber_height - cy + padding) * scale + 0.5
    if chamber[cy] and real_y < view_height then
      for cx = 1, chamber_width do
        if chamber[cy][cx] and chamber[cy][cx] > 0 then
          love.graphics.setColor(unpack(colors[chamber[cy][cx]]))
          love.graphics.rectangle(
            "fill",
            (cx + padding) * scale + 0.5,
            real_y,
            scale,
            scale
          )

          love.graphics.setColor(0, 0, 0)
          love.graphics.rectangle(
            "line",
            (cx + padding) * scale + 0.5,
            real_y,
            scale,
            scale
          )
        end
      end
    end
  end
end
