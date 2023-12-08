class Position
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def +(direction)
    Position.new(x + direction.dx, y + direction.dy)
  end

  def negative?
    x < 0 || y < 0
  end

  def inspect
    "(#{x}, #{y})"
  end
end

class Direction
  attr_reader :dx, :dy

  def initialize(dx, dy)
    @dx, @dy = dx, dy
  end

  NORTH = Direction.new(0, -1)
  EAST = Direction.new(1, 0)
  SOUTH = Direction.new(0, 1)
  WEST = Direction.new(-1, 0)
  CLOCKWISE = [NORTH, EAST, SOUTH, WEST]

  alias :=== :==
  def ==(other)
    [dx, dy] == [other.dx, other.dy]
  end

  def inspect
    case self
    when NORTH then "North"
    when EAST then "East"
    when WEST then "West"
    when SOUTH then "South"
    else
      [@dx, @dy].inspect
    end
  end

  def turn_right
    CLOCKWISE[(CLOCKWISE.find_index(self) + 1) % CLOCKWISE.length]
  end

  def turn_left
    CLOCKWISE[(CLOCKWISE.find_index(self) - 1) % CLOCKWISE.length]
  end
end

class Tile
  def passable?
    true
  end

  def out_of_bounds?
    false
  end

  def inspect
    "?"
  end
end

class Empty < Tile
  def inspect
    "."
  end
end

class Wall < Tile
  def passable?
    false
  end

  def inspect
    "#"
  end
end

class Void < Tile
  def passable?
    false
  end

  def out_of_bounds?
    true
  end

  def inspect
    " "
  end
end

class Board
  def initialize(tiles)
    @tiles = tiles
  end

  def [](position)
    (!position.negative? && @tiles.dig(position.y, position.x)) || Void.new
  end

  def start_position
    Position.new(@tiles[0].find_index(&:passable?), 0)
  end

  def step_forward(position, direction)
    next_position = position + direction

    if self[next_position].out_of_bounds?
      wrap_from(position, direction)
    else
      next_position
    end
  end

  private

  def wrap_from(position, direction)
    cur_position = case direction
    when Direction::EAST then Position.new(0, position.y)
    when Direction::WEST then Position.new(@tiles[position.y].length - 1, position.y)
    when Direction::SOUTH then Position.new(position.x, 0)
    when Direction::NORTH then Position.new(position.x, @tiles.length - 1)
    end

    cur_position += direction while self[cur_position].out_of_bounds?
    cur_position
  end
end

class Instruction
  def execute(state)
  end
end

class Move < Instruction
  def initialize(steps)
    @steps = steps
  end

  def execute(state)
    @steps.times do
      next_position = state.board.step_forward(state.position, state.direction)
      break if not state.board[next_position].passable?
      state.position = next_position
    end
  end

  def inspect
    "#{@steps}↑"
  end
end

class TurnRight < Instruction
  def execute(state)
    state.direction = state.direction.turn_right
  end

  def inspect
    "↱"
  end
end

class TurnLeft < Instruction
  def execute(state)
    state.direction = state.direction.turn_left
  end

  def inspect
    "↰"
  end
end

class State
  attr_accessor :board, :position, :direction

  def initialize(board)
    @board = board
    @position = board.start_position
    @direction = Direction::EAST
  end
end

class Simulation
  def run(board, instructions)
    state = State.new(board)
    instructions.each { _1.execute(state) }
    state
  end
end

class Password
  attr_reader :position, :direction

  def initialize(position, direction)
    @position, @direction = position, direction
  end

  def to_answer
    facing = case @direction
    when Direction::EAST then 0
    when Direction::SOUTH then 1
    when Direction::WEST then 2
    when Direction::NORTH then 3
    end

    (1000 * (@position.y + 1)) + (4 * (@position.x + 1)) + facing
  end
end

class Puzzle
  def initialize(input)
    parse!(input)
  end

  def self.from_file(path)
    self.new(File.open(path, "r"))
  end

  def self.from_string(input)
    self.new(StringIO.new(input))
  end

  def solve
  end

  protected

  def parse!(input)
  end
end

class MonkeyMapPuzzle < Puzzle
  attr_reader :board, :instructions

  def solve
    final_state = Simulation.new.run(@board, @instructions)
    Password.new(final_state.position, final_state.direction)
  end

  protected

  def parse!(input)
    contents = input.read.split("\n\n")
    input.close

    @board = parse_board(contents[0])
    @instructions = parse_instructions(contents[1])
  end

  private

  def parse_board(text)
    Board.new(text.lines.map(&:chomp).map { |line| line.chars.map { parse_tile(_1) } })
  end

  def parse_tile(char)
    {
      "." => Empty.new,
      "#" => Wall.new,
    }[char] || Void.new
  end

  def parse_instructions(text)
    text.scan(/(\d+)([RL]?)/).map do |steps, turn|
      [Move.new(steps.to_i), {?R => TurnRight.new, ?L => TurnLeft.new}[turn]]
    end.flatten.compact
  end
end

if ENV["TEST"]
  require "minitest/autorun"
  require "minitest/pride"

  class MonkeyMapPuzzleTest < Minitest::Test
    def test_big
      assert_equal 36518, MonkeyMapPuzzle.from_file("input").solve.to_answer
    end

    def test_small
      input = <<~INPUT
                ...#
                .#..
                #...
                ....
        ...#.......#
        ........#...
        ..#....#....
        ..........#.
                ...#....
                .....#..
                .#......
                ......#.

        10R5L5R10L4R5L5
      INPUT

      assert_equal 6032, MonkeyMapPuzzle.from_string(input).solve.to_answer
    end
  end
else
  puts MonkeyMapPuzzle.from_file("input").solve.to_answer
end
