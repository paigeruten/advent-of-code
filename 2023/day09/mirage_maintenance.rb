require_relative "../common"

module MirageMaintenance
  class Sequence
    def initialize(numbers)
      @numbers = numbers
    end

    def predict_next_value
      all_zeroes? ? 0 : @numbers.last + differences.predict_next_value
    end

    def predict_prev_value
      all_zeroes? ? 0 : @numbers.first - differences.predict_prev_value
    end

    def differences
      Sequence.new(@numbers.each_cons(2).map { |a, b| b - a })
    end

    def all_zeroes?
      @numbers.all?(&:zero?)
    end
  end
end

class MirageMaintenancePuzzle < Puzzle
  include MirageMaintenance

  attr_reader :sequences

  def initialize(sequences)
    @sequences = sequences
  end

  def solve_part_one
    sequences.sum(&:predict_next_value)
  end

  def solve_part_two
    sequences.sum(&:predict_prev_value)
  end

  def self.parse(input)
    sequences = input.lines.map { |line| Sequence.new(line.split.map(&:to_i)) }
    new(sequences)
  end
end

if test?
  class MirageMaintenancePuzzleTest < Minitest::Test
    include MirageMaintenance

    EXAMPLE_INPUT = <<~EOF
      0 3 6 9 12 15
      1 3 6 10 15 21
      10 13 16 21 30 45
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_example_input_part_one
      assert_equal 114, MirageMaintenancePuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 2101499000, MirageMaintenancePuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 2, MirageMaintenancePuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 1089, MirageMaintenancePuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end

  class SequenceTest < Minitest::Test
    include MirageMaintenance

    def test_predict_next_value_of_first_example
      assert_equal 18, Sequence.new([0, 3, 6, 9, 12, 15]).predict_next_value
    end

    def test_predict_next_value_of_second_example
      assert_equal 28, Sequence.new([1, 3, 6, 10, 15, 21]).predict_next_value
    end

    def test_predict_next_value_of_third_example
      assert_equal 68, Sequence.new([10, 13, 16, 21, 30, 45]).predict_next_value
    end
  end
end
