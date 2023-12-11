require_relative "../common"

module CosmicExpansion
  module Refinements
    refine Array do
      # Efficiently counts how many elements in the array are in the given
      # range (assuming the array is sorted).
      def count_in_range(range)
        left = bsearch_index { _1 > range.begin }
        return 0 if left.nil?
        right = bsearch_index { _1 > range.end } || length

        right - left
      end
    end
  end

  class Universe
    include BasicEquality
    using Refinements

    attr_reader :galaxies, :empty_rows, :empty_cols, :expansion_factor

    def initialize(galaxies, empty_rows, empty_cols)
      @galaxies, @empty_rows, @empty_cols = galaxies, empty_rows, empty_cols
      @expansion_factor = 1
    end

    def expand(factor)
      @expansion_factor = factor
      self
    end

    def self.from_image(image)
      galaxies = []
      image.each.with_index do |row, y|
        row.each.with_index do |char, x|
          galaxies << Galaxy.new(x, y) if char == ?#
        end
      end

      transposed = image.transpose
      empty_rows = (0...image.length)
        .select { |y| not image[y].include?(?#) }
      empty_cols = (0...transposed.length)
        .select { |x| not transposed[x].include?(?#) }

      new(galaxies, empty_rows, empty_cols)
    end

    def sum_of_shortest_paths
      galaxies
        .combination(2)
        .sum { shortest_path(_1, _2) }
    end

    def shortest_path(galaxy1, galaxy2)
      galaxy1.manhattan_distance(galaxy2) + expanded_space(galaxy1, galaxy2)
    end

    def expanded_space(galaxy1, galaxy2)
      expanded_columns = empty_cols.count_in_range(galaxy1.x_range(galaxy2))
      expanded_rows = empty_rows.count_in_range(galaxy1.y_range(galaxy2))

      (expanded_columns + expanded_rows) * (expansion_factor - 1)
    end
  end

  class Galaxy
    include BasicEquality

    attr_reader :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def manhattan_distance(other)
      (self.x - other.x).abs + (self.y - other.y).abs
    end

    def x_range(other)
      self.x <= other.x ? (self.x..other.x) : (other.x..self.x)
    end

    def y_range(other)
      self.y <= other.y ? (self.y..other.y) : (other.y..self.y)
    end
  end
end

class CosmicExpansionPuzzle < Puzzle
  include CosmicExpansion

  attr_reader :universe

  def initialize(universe)
    @universe = universe
  end

  def solve_part_one
    universe.expand(2).sum_of_shortest_paths
  end

  def solve_part_two
    universe.expand(1_000_000).sum_of_shortest_paths
  end

  def self.parse(input)
    new(Universe.from_image(input.lines.map(&:chomp).map(&:chars)))
  end
end

if test?
  class CosmicExpansionPuzzleTest < Minitest::Test
    include CosmicExpansion

    EXAMPLE_INPUT = <<~EOF
      ...#......
      .......#..
      #.........
      ..........
      ......#...
      .#........
      .........#
      ..........
      .......#..
      #...#.....
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_parse
      expected = Universe.new(
        [
          Galaxy.new(3, 0),
          Galaxy.new(7, 1),
          Galaxy.new(0, 2),
          Galaxy.new(6, 4),
          Galaxy.new(1, 5),
          Galaxy.new(9, 6),
          Galaxy.new(7, 8),
          Galaxy.new(0, 9),
          Galaxy.new(4, 9),
        ],
        [3, 7],
        [2, 5, 8]
      )

      assert_equal expected, CosmicExpansionPuzzle.parse(EXAMPLE_INPUT).universe
    end

    def test_example_input_part_one
      assert_equal 374, CosmicExpansionPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 9403026, CosmicExpansionPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two_10x
      assert_equal 1030, CosmicExpansionPuzzle.parse(EXAMPLE_INPUT).universe.expand(10).sum_of_shortest_paths
    end

    def test_example_input_part_two_100x
      assert_equal 8410, CosmicExpansionPuzzle.parse(EXAMPLE_INPUT).universe.expand(100).sum_of_shortest_paths
    end

    def test_actual_input_part_two
      assert_equal 543018317006, CosmicExpansionPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
