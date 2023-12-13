require_relative "../common"

module PointOfIncidence
  class Pattern
    attr_reader :tiles, :has_smudge

    def initialize(tiles, has_smudge = false)
      @tiles = tiles
      @has_smudge = has_smudge
    end

    def self.from_string(input)
      new(input.lines.map(&:chomp).map(&:chars))
    end

    def with_smudge
      @has_smudge = true
      self
    end

    def line_of_reflection
      horizontal_line_of_reflection || vertical_line_of_reflection
    end

    def horizontal_line_of_reflection
      0.upto(height - 2).each do |idx|
        reflected_height = [idx + 1, height - idx - 1].min
        rows_above = @tiles[(idx - reflected_height + 1)..idx]
        rows_below = @tiles[(idx + 1)..(idx + reflected_height)]
        row_pairs = rows_above.zip(rows_below.reverse)
        return LineOfReflection.horizontal(idx + 1) if row_pairs_equal?(row_pairs)
      end
      nil
    end

    def vertical_line_of_reflection
      position = transpose.horizontal_line_of_reflection&.position
      position ? LineOfReflection.vertical(position) : nil
    end

    def row_pairs_equal?(row_pairs)
      total_chars = row_pairs.sum { |row1, _| row1.length }
      matching_chars = row_pairs.sum { |row1, row2| row1.zip(row2).count { |a, b| a == b } }
      matching_chars == (has_smudge ? total_chars - 1 : total_chars)
    end

    def height
      @tiles.length
    end

    def transpose
      Pattern.new(@tiles.transpose, @has_smudge)
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

  def solve_part_two
    patterns.map(&:with_smudge).map(&:line_of_reflection).sum(&:summary)
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
      assert_equal 400, PointOfIncidencePuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 28475, PointOfIncidencePuzzle.parse(ACTUAL_INPUT).solve_part_two
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
