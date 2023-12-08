SHAPES = [
  [
    [1,1,1,1]
  ],
  [
    [0,1,0],
    [1,1,1],
    [0,1,0]
  ],
  [
    [0,0,1],
    [0,0,1],
    [1,1,1]
  ],
  [
    [1],
    [1],
    [1],
    [1]
  ],
  [
    [1,1],
    [1,1]
  ]
]

class Chamber
  attr_reader :width, :height, :blocks

  def initialize(width)
    @blocks = []
    @width = width
    @height = 0
  end

  def blit(shape, x, y, mode)
    (0...shape.length).each do |sy|
      (0...shape[sy].length).each do |sx|
        if shape[sy][sx] == 1
          cy = y - sy
          cx = x + sx
          @blocks[cy] ||= []
          @blocks[cy][cx] = mode
        end
      end
    end
    @height = [@height, y].max
  end

  def collision?(shape, x, y)
    return true if x < 0 or y - shape.length + 1 < 0 or x + shape[0].length > @width

    (0...shape.length).each do |sy|
      (0...shape[sy].length).each do |sx|
        if shape[sy][sx] == 1 then
          cy = y - sy
          cx = x + sx
          return true if @blocks[cy] && @blocks[cy][cx] == :locked
        end
      end
    end

    false
  end

  def print!
    (@height..0).step(-1).each do |y|
      (0...@width).each do |x|
        block = @blocks[y] && @blocks[y][x]
        case block
        when :locked
          print "#"
        when :unlocked
          print "@"
        else
          print "."
        end
      end
      print "\n"
    end
    print "\n"
  end
end

jets = File.read("input").chomp

chamber = Chamber.new(7)
state = :drop
num_fallen = 0
tower_height = 0
cur_shape = 0
cur_jet = 0
cur_shape_x = nil
cur_shape_y = nil

step = lambda do
  case state
  when :drop
    cur_shape_x = 2
    cur_shape_y = tower_height + 2 + SHAPES[cur_shape].length
    chamber.blit(SHAPES[cur_shape], cur_shape_x, cur_shape_y, :unlocked)

    state = :jet
  when :jet
    dx = { "<" => -1, ">" => 1 }[jets[cur_jet]]

    unless chamber.collision?(SHAPES[cur_shape], cur_shape_x + dx, cur_shape_y)
      chamber.blit(SHAPES[cur_shape], cur_shape_x, cur_shape_y, nil)
      cur_shape_x += dx
      chamber.blit(SHAPES[cur_shape], cur_shape_x, cur_shape_y, :unlocked)
    end

    cur_jet = (cur_jet + 1) % jets.length
    state = :fall
  when :fall
    if chamber.collision?(SHAPES[cur_shape], cur_shape_x, cur_shape_y - 1)
      chamber.blit(SHAPES[cur_shape], cur_shape_x, cur_shape_y, :locked)

      num_fallen += 1
      tower_height = [tower_height, cur_shape_y + 1].max
      cur_shape = (cur_shape + 1) % SHAPES.length
      state = :drop
    else
      chamber.blit(SHAPES[cur_shape], cur_shape_x, cur_shape_y, nil)
      cur_shape_y -= 1
      chamber.blit(SHAPES[cur_shape], cur_shape_x, cur_shape_y, :unlocked)

      state = :jet
    end
  end
end

# start looking for a cycle after 2022 rocks have fallen
step.() until num_fallen == 2022 && state == :drop

snapshot_num_fallen = 2022
snapshot_tower_height = tower_height
snapshot_cur_shape = cur_shape
snapshot_cur_jet = cur_jet

# keep stepping until we're back to 2022's shape and jet
step.()
step.() until cur_shape == snapshot_cur_shape && cur_jet == snapshot_cur_jet && state == :drop

tower_height_diff = tower_height - snapshot_tower_height
num_fallen_diff = num_fallen - snapshot_num_fallen

num_rocks_left = 1000000000000 - num_fallen
cycles = (num_rocks_left / num_fallen_diff).floor
rocks_leftover = num_rocks_left % num_fallen_diff

# simulate whatever rocks are leftover after the cycling part
max_num_fallen = num_fallen + rocks_leftover
step.() until num_fallen == max_num_fallen

# add in the cycling tower height
tower_height += cycles * tower_height_diff
num_fallen += cycles * num_fallen_diff

p tower_height
