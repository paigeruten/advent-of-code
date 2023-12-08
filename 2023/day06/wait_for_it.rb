require_relative "../common"

module WaitForIt
  class Race
    include BasicEquality

    attr_reader :time, :record_distance

    def initialize(time, record_distance)
      @time, @record_distance = time, record_distance
    end

    def number_of_record_beating_strategies
      left = 0
      right = time / 2

      while left < right - 1
        middle = (right + left) / 2
        distance = middle * (time - middle)
        if distance > record_distance
          right = middle
        else
          left = middle
        end
      end

      if time.even?
        (time / 2 - right) * 2 + 1
      else
        ((time / 2 + 1) - right) * 2
      end
    end
  end
end

class WaitForItPuzzle < Puzzle
  include WaitForIt

  attr_reader :little_races, :big_race

  def initialize(little_races, big_race)
    @little_races, @big_race = little_races, big_race
  end

  def solve_part_one
    little_races.map(&:number_of_record_beating_strategies).inject(:*)
  end

  def solve_part_two
    big_race.number_of_record_beating_strategies
  end

  def self.parse(input)
    time_line, distance_line = input.lines
    times = time_line.scan(/\d+/)
    distances = distance_line.scan(/\d+/)

    little_races = times.zip(distances)
      .map { |time, distance| Race.new(time.to_i, distance.to_i) }
    big_race = Race.new(times.join.to_i, distances.join.to_i)

    new(little_races, big_race)
  end
end

if test?
  class WaitForItPuzzleTest < Minitest::Test
    include WaitForIt

    EXAMPLE_INPUT = <<~EOF
      Time:      7  15   30
      Distance:  9  40  200
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    def test_parse
      expected_little_races = [
        Race.new(7, 9),
        Race.new(15, 40),
        Race.new(30, 200),
      ]
      expected_big_race = Race.new(71530, 940200)

      parsed = WaitForItPuzzle.parse(EXAMPLE_INPUT)

      assert_equal expected_little_races, parsed.little_races
      assert_equal expected_big_race, parsed.big_race
    end

    def test_example_input_part_one
      assert_equal 288, WaitForItPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 1731600, WaitForItPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 71503, WaitForItPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 40087680, WaitForItPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end

  class RaceTest < Minitest::Test
    include WaitForIt

    def test_number_of_record_beating_strategies_for_7ms
      assert_equal 4, Race.new(7, 9).number_of_record_beating_strategies
    end

    def test_number_of_record_beating_strategies_for_15ms
      assert_equal 8, Race.new(15, 40).number_of_record_beating_strategies
    end

    def test_number_of_record_beating_strategies_for_30ms
      assert_equal 9, Race.new(30, 200).number_of_record_beating_strategies
    end
  end
end
