require_relative "../common"

module StepCounter
  class Map
    def initialize(tiles)
      @tiles = tiles
      @wrappable = false
      find_start!
    end

    def wrappable!
      @wrappable = true
      self
    end

    def wrappable
      dup.wrappable!
    end

    def [](x, y)
      x, y = x % @tiles.first.length, y % @tiles.length if @wrappable
      @tiles.dig(y, x) if x >= 0 && y >= 0
    end

    def reachable_plots(steps)
      positions = [@start]

      steps.times do
        next_positions = []

        positions.each do |x, y|
          [[x, y - 1], [x + 1, y], [x, y + 1], [x - 1, y]].each do |nx, ny|
            next_positions << [nx, ny] if self[nx, ny] == ?.
          end
        end

        positions = next_positions.uniq
      end

      positions.length
    end

    private

    def find_start!
      (0...@tiles.length).each do |y|
        (0...@tiles[y].length).each do |x|
          if @tiles[y][x] == ?S
            @start = [x, y]
            @tiles[y][x] = ?.
            return
          end
        end
      end
      raise "start not found"
    end
  end
end

class StepCounterPuzzle < Puzzle
  include StepCounter

  attr_reader :map

  def initialize(map)
    @map = map
  end

  def solve_part_one
    map.reachable_plots(64)
  end

  def solve_part_two
    map.wrappable.reachable_plots(26_501_365)
  end

  def self.parse(input)
    tiles = input.lines.map(&:chomp).map(&:chars)
    new(Map.new(tiles))
  end
end

if test?
  class StepCounterPuzzleTest < Minitest::Test
    include StepCounter

    EXAMPLE_INPUT = <<~EOF
      ...........
      .....###.#.
      .###.##..#.
      ..#.#...#..
      ....#.#....
      .##..S####.
      .##..#...#.
      .......##..
      .##.#.####.
      .##..##.##.
      ...........
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 16, StepCounterPuzzle.parse(EXAMPLE_INPUT).map.reachable_plots(6)
    end

    def test_actual_input_part_one
      assert_equal 3830, StepCounterPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 6536, StepCounterPuzzle.parse(EXAMPLE_INPUT).map.wrappable.reachable_plots(100)
    end

    def test_actual_input_part_two
      skip
      assert_equal ??, StepCounterPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
