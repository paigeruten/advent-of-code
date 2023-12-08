require_relative "../common.rb"
require "paco"

module CubeConundrum
  class Game
    include BasicEquality

    attr_reader :id, :reveals

    def initialize(id, reveals)
      @id, @reveals = id, reveals
    end

    def possible?(max_cubes)
      @reveals.all? { _1.subset?(max_cubes) }
    end

    def smallest_possible_cube_count
      CubeCount.new(
        red: @reveals.map(&:red).max,
        green: @reveals.map(&:green).max,
        blue: @reveals.map(&:blue).max,
      )
    end
  end

  class CubeCount
    include BasicEquality

    attr_reader :red, :green, :blue

    def initialize(red: 0, green: 0, blue: 0)
      @red, @green, @blue = red, green, blue
    end

    def subset?(other)
      red <= other.red && green <= other.green && blue <= other.blue
    end

    def power
      red * green * blue
    end
  end
end

class CubeConundrumPuzzle < Puzzle
  include CubeConundrum

  attr_reader :games

  def initialize(games)
    @games = games
  end

  def solve_part_one
    max_cubes = CubeCount.new(red: 12, green: 13, blue: 14)
    games.select { _1.possible?(max_cubes) }.sum(&:id)
  end

  def solve_part_two
    games.map(&:smallest_possible_cube_count).sum(&:power)
  end

  class << self
    include CubeConundrum
    include Paco

    def parse(input)
      integer = digits.fmap(&:to_i)
      color = alt(string("red"), string("green"), string("blue")).fmap(&:to_sym)
      cube_count = sep_by!(seq(integer.skip(ws), color), spaced(string(",")))
        .fmap { |counts| CubeCount.new(**counts.map(&:reverse).to_h) }
      game = seq(
        string("Game").next(ws).next(integer).skip(spaced(string(":"))),
        sep_by!(cube_count, spaced(string(";")))
      )
        .fmap { |id, cube_counts| Game.new(id, cube_counts) }
      games = many(spaced(game))

      new(games.parse(input))
    end
  end
end

if test?
  class CubeConundrumPuzzleTest < Minitest::Test
    EXAMPLE_INPUT = <<~EOF
      Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
      Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
      Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
      Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
      Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    EOF

    ACTUAL_INPUT = File.read("#{__dir__}/input")

    include CubeConundrum

    def test_parse
      input = <<~EOF
        Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
      EOF

      expected = [
        Game.new(1, [
          CubeCount.new(red: 4, blue: 3),
          CubeCount.new(red: 1, green: 2, blue: 6),
          CubeCount.new(green: 2),
        ]),
        Game.new(2, [
          CubeCount.new(green: 2, blue: 1),
          CubeCount.new(red: 1, green: 3, blue: 4),
          CubeCount.new(green: 1, blue: 1),
        ]),
      ]

      assert_equal expected, CubeConundrumPuzzle.parse(input).games
    end

    def test_example_input_part_one
      assert_equal 8, CubeConundrumPuzzle.parse(EXAMPLE_INPUT).solve_part_one
    end

    def test_actual_input_part_one
      assert_equal 2164, CubeConundrumPuzzle.parse(ACTUAL_INPUT).solve_part_one
    end

    def test_example_input_part_two
      assert_equal 2286, CubeConundrumPuzzle.parse(EXAMPLE_INPUT).solve_part_two
    end

    def test_actual_input_part_two
      assert_equal 69929, CubeConundrumPuzzle.parse(ACTUAL_INPUT).solve_part_two
    end
  end

  class GameTest < Minitest::Test
    include CubeConundrum

    def test_game_is_possible
      game = Game.new(1, [CubeCount.new(red: 4, blue: 3)])
      max_cubes = CubeCount.new(red: 4, blue: 3, green: 2)

      assert game.possible?(max_cubes)
    end

    def test_game_is_not_possible
      game = Game.new(1, [CubeCount.new(red: 4, blue: 3), CubeCount.new(red: 20, green: 13)])
      max_cubes = CubeCount.new(red: 4, blue: 3, green: 2)

      refute game.possible?(max_cubes)
    end

    def test_smallest_possible_cube_count
      game = Game.new(1, [CubeCount.new(red: 4, blue: 3), CubeCount.new(red: 20, green: 13, blue: 10)])

      assert_equal CubeCount.new(red: 20, green: 13, blue: 10), game.smallest_possible_cube_count
    end
  end

  class CubeCountTest < Minitest::Test
    include CubeConundrum

    def test_power
      assert_equal 48, CubeCount.new(red: 4, green: 2, blue: 6).power
    end
  end
end
