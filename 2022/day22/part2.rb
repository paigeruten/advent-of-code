input = File.read("input").split("\n\n")

map = input[0].lines.map(&:chomp).map(&:chars)
path = input[1].scan(/(\d+)([RL]?)/).map do |steps, turn|
  [steps.to_i, {"R" => :right, "L" => :left}[turn]]
end

NORTH = [0, -1]
EAST = [1, 0]
SOUTH = [0, 1]
WEST = [-1, 0]
DIRECTIONS = [NORTH, EAST, SOUTH, WEST]

FACE_SIZE = 50
FACES = {
  a: [1, 0],
  b: [2, 0],
  c: [1, 1],
  d: [0, 2],
  e: [1, 2],
  f: [0, 3],
}
FACE_WRAPS = {
  [:b, NORTH] => [:f, NORTH],
  [:a, NORTH] => [:f, EAST],
  [:d, NORTH] => [:c, EAST],
  [:c, EAST] => [:b, NORTH],
  [:f, EAST] => [:e, NORTH],
  [:b, EAST] => [:e, WEST],
  [:e, EAST] => [:b, WEST],
  [:b, SOUTH] => [:c, WEST],
  [:e, SOUTH] => [:f, WEST],
  [:f, SOUTH] => [:b, SOUTH],
  [:a, WEST] => [:d, EAST],
  [:d, WEST] => [:a, EAST],
  [:c, WEST] => [:d, SOUTH],
  [:f, WEST] => [:a, SOUTH],
}

def get_face(x, y)
  FACES.invert[[x / FACE_SIZE, y / FACE_SIZE]]
end

def local_to_global(face, pos)
  [FACES[face][0] * FACE_SIZE + pos[0], FACES[face][1] * FACE_SIZE + pos[1]]
end

def global_to_local(face, pos)
  [pos[0] - FACES[face][0] * FACE_SIZE, pos[1] - FACES[face][1] * FACE_SIZE]
end

def out_of_bounds?(x, y, map)
  x < 0 || y < 0 || map[y] == nil || map[y][x] == nil || map[y][x] == " "
end

def wrap(x, y, dir, map)
  face = get_face(x, y)
  raise "don't know how to wrap from #{face.inspect} going #{dir.inspect}" unless FACE_WRAPS[[face, dir]]
  new_face, new_dir = FACE_WRAPS[[face, dir]]
  local_x, local_y = global_to_local(face, [x, y])

  new_local_pos = case [dir, new_dir]
  when [NORTH, NORTH]
    [local_x, FACE_SIZE - 1]
  when [EAST, NORTH]
    [local_y, FACE_SIZE - 1]
  when [NORTH, EAST]
    [0, local_x]
  when [WEST, EAST]
    [0, FACE_SIZE - 1 - local_y]
  when [EAST, WEST]
    [FACE_SIZE - 1, FACE_SIZE - 1 - local_y]
  when [SOUTH, WEST]
    [FACE_SIZE - 1, local_x]
  when [WEST, SOUTH]
    [local_y, 0]
  when [SOUTH, SOUTH]
    [local_x, 0]
  else
    raise "don't know how to wrap from #{dir.inspect} to #{new_dir.inspect}"
  end

  [*local_to_global(new_face, new_local_pos), new_dir]
end

def move(x, y, dir, map)
  next_x, next_y, next_dir = x + dir[0], y + dir[1], dir

  if out_of_bounds?(next_x, next_y, map)
    next_x, next_y, next_dir = wrap(x, y, dir, map)
  end

  case map[next_y][next_x]
  when "."
    [next_x, next_y, next_dir]
  when "#"
    [x, y, dir]
  else
    raise "trying to move to empty space"
  end
end

def rotate(dir, turn)
  DIRECTIONS[(DIRECTIONS.find_index(dir) + {right: 1, left: -1}[turn]) % DIRECTIONS.length]
end

x = map[0].find_index(".")
y = 0
dir = EAST

path.each do |steps, turn|
  steps.times do
    x, y, dir = move(x, y, dir, map)
  end

  dir = rotate(dir, turn) if turn
end

facing = case dir
when EAST then 0
when SOUTH then 1
when WEST then 2
when NORTH then 3
end

password = (1000 * (y + 1)) + (4 * (x + 1)) + facing
p password
