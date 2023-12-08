require_relative "../common"

module Trebuchet
  class CalibrationDocument
    WORDS = %w(one two three four five six seven eight nine)

    def initialize(lines)
      @lines = lines
      @words = []
    end

    def with_words(words = WORDS) = dup.with_words!(words)
    def with_words!(words = WORDS)
      @words = words
      self
    end

    def sum_of_calibration_values
      @lines.map { CalibrationLine.new(_1, @words) }.sum(&:calibration_value)
    end
  end

  class CalibrationLine
    def initialize(line, words)
      @line = line
      @words = words
    end

    def calibration_value
      (first_digit + last_digit).to_i
    end

    def first_digit
      find_digit(@line, @words)
    end

    def last_digit
      find_digit(@line.reverse, @words.map(&:reverse))
    end

    private

    def find_digit(line, words)
      line.match(words.empty? ? /(\d)/ : /(\d)|(#{words.join ?|})/) do |m|
        m[1] || (words.find_index(m[2]) + 1).to_s
      end
    end
  end
end

class TrebuchetPuzzle < Puzzle
  include Trebuchet

  def initialize(calibration_document)
    @calibration_document = calibration_document
  end

  def solve_part_one
    @calibration_document.sum_of_calibration_values
  end

  def solve_part_two
    @calibration_document.with_words.sum_of_calibration_values
  end

  def self.parse(input)
    lines = input
      .lines
      .map(&:strip)
      .reject(&:empty?)

    new(CalibrationDocument.new(lines))
  end
end

if test?
  class TrebuchetPuzzleTest < Minitest::Test
    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      input = <<~EOF
        1abc2
        pqr3stu8vwx
        a1b2c3d4e5f
        treb7uchet
      EOF

      assert_equal 142, TrebuchetPuzzle.parse(input).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 54_632, TrebuchetPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      input = <<~EOF
        two1nine
        eightwothree
        abcone2threexyz
        xtwone3four
        4nineeightseven2
        zoneight234
        7pqrstsixteen
      EOF

      assert_equal 281, TrebuchetPuzzle.parse(input).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 54_019, TrebuchetPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end
end
