require 'set'

DIRECTIONS = [
  [1, 0, 0],
  [-1, 0, 0],
  [0, 1, 0],
  [0, -1, 0],
  [0, 0, 1],
  [0, 0, -1],
]

cubes = File.readlines("input").map { |line| line.split(",").map(&:to_i) }
cubes_set = Set[*cubes]

min_x = cubes.map { |cube| cube[0] }.min - 1
max_x = cubes.map { |cube| cube[0] }.max + 1
min_y = cubes.map { |cube| cube[1] }.min - 1
max_y = cubes.map { |cube| cube[1] }.max + 1
min_z = cubes.map { |cube| cube[2] }.min - 1
max_z = cubes.map { |cube| cube[2] }.max + 1

in_bounds = lambda do |pos|
  pos[0] >= min_x && pos[0] <= max_x &&
  pos[1] >= min_y && pos[1] <= max_y &&
  pos[2] >= min_z && pos[2] <= max_z
end

steam_set = Set[[min_x, min_y, min_z]]
unvisited = [[min_x, min_y, min_z]]
until unvisited.empty?
  pos = unvisited.shift
  DIRECTIONS.each do |dir|
    neighbour = pos.zip(dir).map { |a, b| a + b }
    if in_bounds.(neighbour) && !steam_set.include?(neighbour) && !cubes_set.include?(neighbour)
      unvisited.push(neighbour)
      steam_set.add(neighbour)
    end
  end
end

def count_exposed_sides(cube, steam_set)
  DIRECTIONS.count { |dir| steam_set.include?(cube.zip(dir).map { |a, b| a + b }) }
end

surface_area = cubes.map { |cube| count_exposed_sides(cube, steam_set) }.sum
p surface_area
