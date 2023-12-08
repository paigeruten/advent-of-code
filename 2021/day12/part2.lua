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

local function is_path_valid(path)
  local cave_freq = {}
  for _, cave in ipairs(path) do
    cave_freq[cave] = (cave_freq[cave] or 0) + 1
  end

  local visited_small_cave_twice = false
  for cave, freq in pairs(cave_freq) do
    if cave == "start" or cave == "end" then
      if freq > 1 then
        return false
      end
    elseif not is_uppercase(cave) then
      if freq > 2 then
        return false
      end
      if freq > 1 and visited_small_cave_twice then
        return false
      end
      if freq > 1 then
        visited_small_cave_twice = true
      end
    end
  end

  return true
end

local function walk(from_path)
  local current_cave = from_path[#from_path]
  if current_cave == "end" then
    return {from_path}
  end

  local finished_paths = {}
  for next_cave in pairs(cave_links[current_cave]) do
    local next_path = table.clone(from_path)
    table.insert(next_path, next_cave)
    if is_path_valid(next_path) then
      for _, finished_path in ipairs(walk(next_path)) do
        table.insert(finished_paths, finished_path)
      end
    end
  end

  return finished_paths
end

local paths = walk({"start"})
print(#paths)
