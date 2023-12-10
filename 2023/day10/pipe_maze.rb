require_relative "../common"

module PipeMaze
  class Grid
    attr_reader :tiles, :start

    def initialize(tiles)
      @tiles = tiles
      find_start!
    end

    def pipe_loop_diameter
      pos1, pos2 = connected_neighbours(start)
      prev1, prev2 = start, start
      num_steps = 1
      while pos1 != pos2
        pos1, prev1 = connected_neighbours(pos1).find { _1 != prev1 }, pos1
        pos2, prev2 = connected_neighbours(pos2).find { _1 != prev2 }, pos2
        num_steps += 1
      end

      num_steps
    end

    def connected_neighbours(pos)
      tile = self[pos]
      result = tile.pipe_directions.filter_map do |direction|
        next_pos = direction + pos
        next_tile = self[next_pos]
        next_pos if next_tile && next_tile.pipe_directions.include?(direction.reverse)
      end
    end

    def [](pos)
      x, y = pos
      Tile.new(@tiles[y][x]) if x >= 0 && y >= 0 && @tiles[y][x]
    end

    private

    def find_start!
      @start = @tiles.each.with_index do |row, y|
        x = row.index(?S)
        break [x, y] if x
      end
    end
  end

  class Tile
    def initialize(char)
      @char = char
    end

    def pipe_directions
      ({
        ?| => %i(north south),
        ?- => %i(east west),
        ?L => %i(north east),
        ?J => %i(north west),
        ?7 => %i(south west),
        ?F => %i(south east),
        ?S => %i(north west south east),
      }[@char] || []).map { Direction.new(_1) }
    end
  end

  class Direction
    attr_reader :direction

    def initialize(direction)
      @direction = direction
    end

    def ==(other)
      self.direction == other.direction
    end

    def +(pos)
      x, y = pos
      dx, dy = delta
      [x + dx, y + dy]
    end

    def delta
      {
        north: [0, -1],
        west: [-1, 0],
        south: [0, 1],
        east: [1, 0],
      }[@direction]
    end

    def reverse
      Direction.new({
        north: :south,
        west: :east,
        south: :north,
        east: :west,
      }[@direction])
    end
  end
end

class PipeMazePuzzle < Puzzle
  include PipeMaze

  attr_reader :grid

  def initialize(grid)
    @grid = grid
  end

  def solve_part_one
    grid.pipe_loop_diameter
  end

  def solve_part_two
  end

  def self.parse(input)
    new(Grid.new(input.lines.map(&:chomp).map(&:chars)))
  end
end

if test?
  class PipeMazePuzzleTest < Minitest::Test
    include PipeMaze

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_first_example_input_part_one
      input = <<~EOF
        -L|F7
        7S-7|
        L|7||
        -L-J|
        L|-JF
      EOF

      assert_equal 4, PipeMazePuzzle.parse(input).solve_part_one
    end

    def test_second_example_input_part_one
      input = <<~EOF
        7-F7-
        .FJ|7
        SJLL7
        |F--J
        LJ.LJ
      EOF

      assert_equal 8, PipeMazePuzzle.parse(input).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 6649, PipeMazePuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      skip
      assert_equal ??, PipeMazePuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      skip
      assert_equal ??, PipeMazePuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
