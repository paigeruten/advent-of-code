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

def count_visible_sides(cube, cubes_set)
  DIRECTIONS.count { |dir| not cubes_set.include?(cube.zip(dir).map { |a, b| a + b }) }
end

surface_area = cubes.map { |cube| count_visible_sides(cube, cubes_set) }.sum
p surface_area
