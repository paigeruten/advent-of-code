dofile("../common.lua")

-- key = cave label, value = set of caves it's connected to
local cave_links = {}

for line in io.lines("input") do
  cave1, cave2 = string.split(line, "-")

  cave_links[cave1] = cave_links[cave1] or {}
  cave_links[cave1][cave2] = true

  cave_links[cave2] = cave_links[cave2] or {}
  cave_links[cave2][cave1] = true
end

local function is_uppercase(cave)
  return string.match(cave, "^%u+$")
end

local function walk(from_path)
  local current_cave = from_path[#from_path]
  if current_cave == "end" then
    return {from_path}
  end

  local finished_paths = {}
  for next_cave in pairs(cave_links[current_cave]) do
    if is_uppercase(next_cave) or not table.includes(from_path, next_cave) then
      local next_path = table.clone(from_path)
      table.insert(next_path, next_cave)

      for _, finished_path in ipairs(walk(next_path)) do
        table.insert(finished_paths, finished_path)
      end
    end
  end

  return finished_paths
end

local paths = walk({"start"})
print(#paths)
