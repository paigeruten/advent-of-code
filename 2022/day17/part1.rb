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

while num_fallen < 2022
  step.()
  #p num_fallen
  #p tower_height
  #chamber.print!
  #sleep 1
end

p tower_height
