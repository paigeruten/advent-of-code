require_relative "../common"

module PointOfIncidence
  class Pattern
    attr_reader :tiles

    def initialize(tiles)
      @tiles = tiles
    end

    def self.from_string(input)
      new(input.lines.map(&:chomp).map(&:chars))
    end

    def line_of_reflection
      horizontal_line_of_reflection || vertical_line_of_reflection
    end

    def horizontal_line_of_reflection
      matching_pairs = @tiles
        .each_cons(2)
        .with_index
        .filter_map { |pair, idx| idx if pair[0] == pair[1] }

      matching_pairs.each do |idx|
        reflected_height = [idx + 1, height - idx - 1].min
        lines_above = @tiles[(idx - reflected_height + 1)..idx]
        lines_below = @tiles[(idx + 1)..(idx + reflected_height)]
        return LineOfReflection.horizontal(idx + 1) if lines_above == lines_below.reverse
      end
      nil
    end

    def vertical_line_of_reflection
      position = transpose.horizontal_line_of_reflection&.position
      position ? LineOfReflection.vertical(position) : nil
    end

    def height
      @tiles.length
    end

    def transpose
      Pattern.new(@tiles.transpose)
    end
  end

  class LineOfReflection
    include BasicEquality

    attr_reader :orientation, :position

    def initialize(orientation, position)
      @orientation, @position = orientation, position
    end

    def self.vertical(position)
      new(:vertical, position)
    end

    def self.horizontal(position)
      new(:horizontal, position)
    end

    def summary
      case orientation
      when :vertical
        position
      when :horizontal
        position * 100
      end
    end
  end
end

class PointOfIncidencePuzzle < Puzzle
  include PointOfIncidence

  attr_reader :patterns

  def initialize(patterns)
    @patterns = patterns
  end

  def solve_part_one
    patterns.map(&:line_of_reflection).sum(&:summary)
  end

  def self.parse(input)
    patterns = input.split("\n\n").map { Pattern.from_string(_1) }
    new(patterns)
  end
end

if test?
  class PointOfIncidencePuzzleTest < Minitest::Test
    include PointOfIncidence

    EXAMPLE_INPUT = <<~EOF
      #.##..##.
      ..#.##.#.
      ##......#
      ##......#
      ..#.##.#.
      ..##..##.
      #.#.##.#.

      #...##..#
      #....#..#
      ..##..###
      #####.##.
      #####.##.
      ..##..###
      #....#..#
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 405, PointOfIncidencePuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 33356, PointOfIncidencePuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      skip
      assert_equal ??, PointOfIncidencePuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      skip
      assert_equal ??, PointOfIncidencePuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end

  class PatternTest < Minitest::Test
    include PointOfIncidence

    def test_vertical_line_of_reflection
      input = <<~EOF
        #.##..##.
        ..#.##.#.
        ##......#
        ##......#
        ..#.##.#.
        ..##..##.
        #.#.##.#.
      EOF

      assert_equal LineOfReflection.vertical(5), Pattern.from_string(input).line_of_reflection
    end

    def test_horizontal_line_of_reflection
      input = <<~EOF
        #...##..#
        #....#..#
        ..##..###
        #####.##.
        #####.##.
        ..##..###
        #....#..#
      EOF

      assert_equal LineOfReflection.horizontal(4), Pattern.from_string(input).line_of_reflection
    end
  end
end
